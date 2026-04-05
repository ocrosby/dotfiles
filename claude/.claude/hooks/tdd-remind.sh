#!/usr/bin/env bash
# PreToolUse TDD reminder hook — fires before Edit/Write on code files
# Outputs a reminder for Claude to follow TDD; Claude sees this as a hook warning.
# Exit 0: allow the tool call to proceed (reminder only, not a block)
set -uo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[[ -z "$FILE" ]] && exit 0

# Only trigger on implementation code files — exit silently for YAML, config,
# Markdown, shell scripts, JSON, and any other non-code file types.
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

echo "TDD REQUIRED: You are about to edit a production file (${FILE})."
echo ""
echo "STOP. Before editing this file you MUST have completed the RED step:"
echo "  1. Written a failing test in the corresponding test file"
echo "  2. Run the test suite and observed the test FAIL"
echo "  3. Shown the failure output to the user"
echo ""
echo "If you have NOT done all three, do not proceed."
echo "Write the failing test first, run it, confirm it fails, THEN come back."
echo ""
echo "Exceptions: /migrate, /refactor, or purely mechanical renames only."
