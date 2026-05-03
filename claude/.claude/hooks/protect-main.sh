#!/usr/bin/env bash
# PreToolUse hook: blocks direct commits to main or master
# Exit non-zero aborts the git commit before it executes.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/protect-main.sh
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Check for direct commits to main/master
if [[ "$COMMAND" == *"git commit"* ]]; then
  # ALLOW_MAIN_COMMIT=1 is set by /ship -m and /ship -p for authorized direct-main commits
  [[ -n "${ALLOW_MAIN_COMMIT:-}" ]] && exit 0
  BRANCH=$(cd "${CLAUDE_PROJECT_DIR:-.}" && git branch --show-current 2>/dev/null)
  if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    echo "[hook: protect-main] ERROR: Direct commit to '$BRANCH' is not allowed."
    echo ""
    echo "  Use /ship -m to commit directly to main, or create a feature branch:"
    echo "    git checkout -b feature/<name>"
    exit 1
  fi
fi

# Check for force-push to main/master
if [[ "$COMMAND" == *"git push"* ]] && ([[ "$COMMAND" == *"--force"* ]] || [[ "$COMMAND" == *" -f "* ]] || [[ "$COMMAND" == *" -f" ]]); then
  if [[ "$COMMAND" == *"main"* || "$COMMAND" == *"master"* ]]; then
    echo "[hook: protect-main] ERROR: Force-push to a protected branch is not allowed."
    echo ""
    echo "  Force-pushing to main/master can overwrite history and break other contributors."
    echo "  If you need to update the remote, use: git push --force-with-lease"
    exit 1
  fi
fi

exit 0
