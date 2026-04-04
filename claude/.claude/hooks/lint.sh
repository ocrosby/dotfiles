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
    ruff check --quiet "$FILE"
    ;;
  go)
    command -v go &>/dev/null || exit 0
    cd "$(dirname "$FILE")" && go vet ./...
    ;;
  lua)
    command -v stylua &>/dev/null || exit 0
    stylua --check "$FILE"
    ;;
  *)
    exit 0
    ;;
esac
