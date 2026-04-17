#!/usr/bin/env bash
# Stop hook: appends a turn-end marker to the debug log.
# Fires when Claude finishes generating a response.
# Provides session boundaries for correlating lint/commit events to specific turns.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/session-stop.sh
set -uo pipefail

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

# Guard against the stop hook triggering itself in a loop
STOP_HOOK_ACTIVE=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
[[ "$STOP_HOOK_ACTIVE" == "true" ]] && exit 0

LOG="$HOME/.claude/hooks/hook-debug.log"
echo "$(date -u +%FT%TZ) [hook: stop] session=$SESSION_ID turn-end" >> "$LOG"

exit 0
