#!/usr/bin/env bash
# PostToolUse hook: validates conventional commit message format after git commit
# Exit non-zero shows a warning to Claude, who can then amend the commit
#
# After stowing, make executable: chmod +x ~/.claude/hooks/commit-msg.sh
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only process git commit commands
[[ "$COMMAND" != *"git commit"* ]] && exit 0
# Skip --amend (already committed, user chose to amend intentionally)
[[ "$COMMAND" == *"--amend"* ]] && exit 0

# Get the actual subject line from the most recent commit
SUBJECT=$(cd "${CLAUDE_PROJECT_DIR:-.}" && git log -1 --pretty=%s 2>/dev/null)
[[ -z "$SUBJECT" ]] && exit 0

# Conventional commits pattern: type(optional-scope)[!]: description
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9/_-]+\))?(!)?: .+'

if ! echo "$SUBJECT" | grep -qE "$PATTERN"; then
  echo "[hook: commit-msg] WARNING: Commit message does not follow Conventional Commits format."
  echo ""
  echo "  Got:      $SUBJECT"
  echo "  Expected: <type>(<scope>): <description>"
  echo "  Types:    feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  echo "  Example:  feat(auth): add JWT token refresh"
  echo ""
  echo "  Fix with: git commit --amend -m \"<corrected message>\""
  exit 1
fi

# Check subject line length
if [[ ${#SUBJECT} -gt 72 ]]; then
  echo "[hook: commit-msg] WARNING: Commit subject is ${#SUBJECT} chars (max 72)."
  echo "  $SUBJECT"
  echo ""
  echo "  Shorten the subject and move details to the commit body."
  echo "  Fix with: git commit --amend"
  exit 1
fi

exit 0
