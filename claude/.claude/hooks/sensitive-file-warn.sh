#!/usr/bin/env bash
# PreToolUse hook: warns when Claude is about to read a sensitive file.
# Always exits 0 (never blocks reads) — the warning surfaces to Claude so it
# avoids echoing secret values back in explanations or diffs.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/sensitive-file-warn.sh
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[[ -z "$FILE" ]] && exit 0

HOOK="[hook: sensitive-file-warn]"
LOG="$HOME/.claude/hooks/hook-debug.log"

# Match on full path — covers .env files, key/cert material, and secrets directories
case "$FILE" in
  */.env | */.env.* | *.env)           ;;  # .env files (any depth)
  *.key | *.pem | *.p12 | *.pfx | *.crt | *.cer) ;;  # key and certificate files
  */credentials.json | */credentials.yml | */credentials.yaml) ;;
  */secrets.json | */secrets.yml | */secrets.yaml) ;;
  */.ssh/* | */.gnupg/*)               ;;  # SSH and GPG key directories
  *) exit 0 ;;
esac

echo "$(date -u +%FT%TZ) $HOOK $FILE" >> "$LOG"
echo "$HOOK WARNING: Reading sensitive file: $FILE"
echo "Do not reproduce the contents of this file verbatim in responses, diffs, or code blocks."

exit 0
