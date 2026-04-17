#!/usr/bin/env bash
# PreCompact hook: logs compaction event and injects current repo state into the
# compaction summary so Claude retains context after the context window is trimmed.
# Stdout is included in the compaction context provided to Claude.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/pre-compact.sh
set -uo pipefail

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
TRIGGER=$(printf '%s' "$INPUT" | jq -r '.trigger // "auto"' 2>/dev/null)

LOG="$HOME/.claude/hooks/hook-debug.log"
echo "$(date -u +%FT%TZ) [hook: pre-compact] session=$SESSION_ID trigger=$TRIGGER" >> "$LOG"

# Inject current repo state into the compaction so post-compaction context is preserved.
# Only emit if inside a git working tree.
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STATUS=$(git status --short 2>/dev/null | head -20)
  RECENT=$(git log --oneline -5 2>/dev/null)

  echo "## Repo state at compaction ($(date -u +%FT%TZ))"
  echo ""
  echo "**Branch:** ${BRANCH:-unknown}"
  echo ""
  if [[ -n "$STATUS" ]]; then
    echo "**Modified files:**"
    echo '```'
    echo "$STATUS"
    echo '```'
    echo ""
  fi
  echo "**Recent commits:**"
  echo '```'
  echo "$RECENT"
  echo '```'
fi

exit 0
