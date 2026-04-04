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
      cd "$MODULE_ROOT" && golangci-lint run ./...
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
  *)
    exit 0
    ;;
esac
