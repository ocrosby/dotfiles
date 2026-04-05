#!/usr/bin/env bash
# PostToolUse lint hook — runs after Edit/Write tool calls
# Exit 0: clean (silent), exit non-zero: lint issues found (output shown to Claude)
#
# After stowing, make executable: chmod +x ~/.claude/hooks/lint.sh
set -uo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit silently if no file path or file doesn't exist
[[ -z "$FILE" ]] && exit 0
[[ ! -f "$FILE" ]] && exit 0

case "${FILE##*.}" in
  py)
    command -v ruff &>/dev/null || exit 0
    ruff check --quiet "$FILE" && ruff format --check --quiet "$FILE"
    ;;
  go)
    command -v go &>/dev/null || exit 0
    # Walk up to the module root so we lint the whole module, not just one package
    MODULE_ROOT="$(dirname "$FILE")"
    while [[ "$MODULE_ROOT" != "/" && ! -f "$MODULE_ROOT/go.mod" ]]; do
      MODULE_ROOT="$(dirname "$MODULE_ROOT")"
    done
    if command -v golangci-lint &>/dev/null; then
      # Warn if local golangci-lint version may be incompatible with the module's Go version
      LOCAL_LINT_VERSION=$(golangci-lint --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+' | head -1)
      MOD_GO_VERSION=$(grep -m1 '^go ' "$MODULE_ROOT/go.mod" 2>/dev/null | awk '{print $2}')
      # golangci-lint v1.x was built with Go <=1.24; v2.x supports Go 1.26+
      if [[ "$MOD_GO_VERSION" == "1.26" || "$MOD_GO_VERSION" > "1.25" ]] && [[ "$LOCAL_LINT_VERSION" == "v1."* ]]; then
        echo "WARNING: golangci-lint $LOCAL_LINT_VERSION was built with Go <=1.24 but go.mod declares go $MOD_GO_VERSION."
        echo "Upgrade to golangci-lint v2.x: go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest"
        echo "Falling back to go vet..."
        cd "$MODULE_ROOT" && go vet ./...
      else
        cd "$MODULE_ROOT" && golangci-lint run ./...
      fi
    else
      cd "$MODULE_ROOT" && go vet ./...
    fi
    ;;
  lua)
    # Run stylua first; also run luacheck if available
    if command -v stylua &>/dev/null; then
      stylua --check "$FILE" || exit 1
    fi
    if command -v luacheck &>/dev/null; then
      luacheck --quiet "$FILE"
    fi
    ;;
  feature)
    command -v gherkin-lint &>/dev/null || exit 0
    gherkin-lint "$FILE"
    ;;
  yml|yaml)
    # Use actionlint for GitHub Actions workflows; yamllint for other YAML files
    case "$FILE" in
      */.github/workflows/*)
        if command -v actionlint &>/dev/null; then
          actionlint "$FILE"
        fi
        ;;
      *)
        if command -v yamllint &>/dev/null; then
          yamllint -d '{extends: relaxed, rules: {line-length: {max: 120}}}' "$FILE"
        fi
        ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac
