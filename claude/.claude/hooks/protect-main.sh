#!/usr/bin/env bash
# PreToolUse hook: blocks direct commits to main or master
# Exit non-zero aborts the git commit before it executes.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/protect-main.sh
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check git commit commands
[[ "$COMMAND" != *"git commit"* ]] && exit 0

# Get current branch
BRANCH=$(cd "${CLAUDE_PROJECT_DIR:-.}" && git branch --show-current 2>/dev/null)

if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "ERROR: Direct commit to '$BRANCH' is not allowed."
  echo ""
  echo "  Create a feature branch first, or use /ship which handles branching automatically."
  echo "    git checkout -b feature/<name>"
  exit 1
fi

exit 0
