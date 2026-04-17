#!/usr/bin/env bash
# PostToolUse lint hook — runs after Edit/Write tool calls
# Exit 0: clean (silent), exit non-zero: lint issues found (output shown to Claude)
#
# After stowing, make executable: chmod +x ~/.claude/hooks/lint.sh
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit silently if no file path or file doesn't exist
[[ -z "$FILE" ]] && exit 0
[[ ! -f "$FILE" ]] && exit 0

HOOK="[hook: lint]"
LOG="$HOME/.claude/hooks/hook-debug.log"

case "${FILE##*.}" in
  py)
    echo "$(date -u +%FT%TZ) $HOOK py: $FILE" >> "$LOG"
    command -v ruff &>/dev/null || exit 0
    echo "$HOOK ruff: checking $FILE"
    ruff check --quiet "$FILE" && ruff format --check --quiet "$FILE"
    ;;
  go)
    echo "$(date -u +%FT%TZ) $HOOK go: $FILE" >> "$LOG"
    command -v go &>/dev/null || exit 0
    # Walk up to the module root so we lint the whole module, not just one package
    MODULE_ROOT="$(dirname "$FILE")"
    while [[ "$MODULE_ROOT" != "/" && ! -f "$MODULE_ROOT/go.mod" ]]; do
      MODULE_ROOT="$(dirname "$MODULE_ROOT")"
    done
    # No go.mod found anywhere in the tree — skip linting
    [[ ! -f "$MODULE_ROOT/go.mod" ]] && exit 0
    if command -v golangci-lint &>/dev/null; then
      # Fail if local golangci-lint version is incompatible with the module's Go version.
      # Do NOT fall back to go vet — it misses godot, goimports, gocyclo and other linters
      # that CI enforces. A false-clean local lint is worse than a clear error.
      LINT_BUILD_GO=$(golangci-lint --version 2>/dev/null | grep -oE 'built with go[0-9.]+' | grep -oE '[0-9]+\.[0-9]+([0-9.]+)?' | head -1)
      MOD_GO_VERSION=$(grep -m1 '^go ' "$MODULE_ROOT/go.mod" 2>/dev/null | awk '{print $2}')
      if [[ -n "$LINT_BUILD_GO" && -n "$MOD_GO_VERSION" ]]; then
        LINT_MINOR=$(echo "$LINT_BUILD_GO" | cut -d. -f2 | sed 's/[^0-9].*//')
        MOD_MINOR=$(echo "$MOD_GO_VERSION" | cut -d. -f2 | sed 's/[^0-9].*//')
        if [[ -n "$LINT_MINOR" && -n "$MOD_MINOR" && "$LINT_MINOR" -lt "$MOD_MINOR" ]]; then
          echo "$HOOK ERROR: golangci-lint was built with go${LINT_BUILD_GO} but go.mod declares go ${MOD_GO_VERSION}."
          echo "golangci-lint will not run and lint issues will reach CI undetected."
          echo ""
          echo "Fix: reinstall golangci-lint using your current Go version:"
          echo "  go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest"
          echo "  (or: task deps  if the project has a Taskfile)"
          exit 1
        fi
      fi
      # Lint only the package containing the changed file, not the whole module.
      # Faster per-edit; run golangci-lint ./... manually for a full module check.
      PKG_DIR="$(dirname "$FILE")"
      if [[ "$PKG_DIR" == "$MODULE_ROOT" ]]; then
        REL_PKG="."
      else
        REL_PKG="${PKG_DIR#${MODULE_ROOT}/}"
      fi
      echo "$HOOK golangci-lint: checking ./$REL_PKG"
      cd "$MODULE_ROOT" && golangci-lint run "./$REL_PKG"
    else
      echo "$HOOK WARNING: golangci-lint not found — install it to catch lint issues before CI:"
      echo "  go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest"
      cd "$MODULE_ROOT" && go vet ./...
    fi
    ;;
  lua)
    echo "$(date -u +%FT%TZ) $HOOK lua: $FILE" >> "$LOG"
    # Run stylua first; also run luacheck if available
    if command -v stylua &>/dev/null; then
      echo "$HOOK stylua: checking $FILE"
      stylua --check "$FILE" || exit 1
    fi
    if command -v luacheck &>/dev/null; then
      echo "$HOOK luacheck: checking $FILE"
      luacheck --quiet "$FILE"
    fi
    ;;
  feature)
    command -v gherkin-lint &>/dev/null || exit 0
    echo "$HOOK gherkin-lint: checking $FILE"
    gherkin-lint "$FILE"
    ;;
  toml)
    if [[ "$(basename "$FILE")" == "pyproject.toml" ]]; then
      command -v uv &>/dev/null || exit 0
      PROJ_DIR="$(dirname "$FILE")"
      [[ -f "$PROJ_DIR/uv.lock" ]] || exit 0
      echo "$HOOK uv lock --check: verifying lockfile is in sync with pyproject.toml"
      if ! (cd "$PROJ_DIR" && uv lock --check 2>&1); then
        echo "$HOOK ERROR: uv.lock is out of sync. Run: uv lock"
        exit 1
      fi
    fi
    ;;
  yml|yaml)
    # Use actionlint for GitHub Actions workflows; yamllint for other YAML files
    case "$FILE" in
      */.github/workflows/*)
        if command -v actionlint &>/dev/null; then
          echo "$HOOK actionlint: checking $FILE"
          actionlint "$FILE"
        fi
        ;;
      *)
        if command -v yamllint &>/dev/null; then
          echo "$HOOK yamllint: checking $FILE"
          yamllint -d '{extends: relaxed, rules: {line-length: {max: 120}}}' "$FILE"
        fi
        ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac
