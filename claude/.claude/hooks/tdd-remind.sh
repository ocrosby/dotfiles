#!/usr/bin/env bash
# PreToolUse TDD reminder hook — fires before Edit/Write on code files
# Outputs a reminder for Claude to follow TDD; Claude sees this as a hook warning.
# Exit 0: allow the tool call to proceed (reminder only, not a block)
set -uo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[[ -z "$FILE" ]] && exit 0

# Only trigger on implementation files, not test files
case "${FILE##*.}" in
  lua|go|py) ;;
  *) exit 0 ;;
esac

# Skip if this IS a test file — TDD in progress, not a violation
BASENAME=$(basename "$FILE")
case "$BASENAME" in
  *_spec.lua|*_test.lua|test_*.py|*_test.py|*_test.go) exit 0 ;;
esac
case "$FILE" in
  */tests/*|*/test/*) exit 0 ;;
esac

echo "TDD CHECK: You are about to edit a production code file (${FILE})."
echo "Before writing implementation code, confirm:"
echo "  1. A failing test exists that requires this change (RED step)"
echo "  2. If not, invoke /test-driven-development and write the test first"
echo "  3. Only skip if this is /migrate, /refactor, or a purely mechanical rename"
