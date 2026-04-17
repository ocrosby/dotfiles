#!/usr/bin/env bash
# UserPromptSubmit hook: blocks prompts that appear to contain credentials
# Exit 2 hard-blocks the prompt; exit 0 allows it through.
#
# After stowing, make executable: chmod +x ~/.claude/hooks/secret-scan.sh
set -uo pipefail

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

[[ -z "$PROMPT" ]] && exit 0

HOOK="[hook: secret-scan]"
LOG="$HOME/.claude/hooks/hook-debug.log"
DETECTED=()

# OpenAI API keys (sk-...)
echo "$PROMPT" | grep -qE 'sk-[a-zA-Z0-9]{20,}' && DETECTED+=("OpenAI API key")
# GitHub personal access / OAuth / app tokens
echo "$PROMPT" | grep -qE 'gh[poas]_[a-zA-Z0-9]{36,}' && DETECTED+=("GitHub token")
# AWS access keys
echo "$PROMPT" | grep -qE 'AKIA[A-Z0-9]{16}' && DETECTED+=("AWS access key")
# Slack tokens
echo "$PROMPT" | grep -qE 'xox[bpsa]-[a-zA-Z0-9-]+' && DETECTED+=("Slack token")
# Google API keys
echo "$PROMPT" | grep -qE 'AIza[0-9A-Za-z_-]{35}' && DETECTED+=("Google API key")
# PEM private key headers
echo "$PROMPT" | grep -qF '-----BEGIN' && DETECTED+=("private key")

if [[ ${#DETECTED[@]} -gt 0 ]]; then
  LABELS=$(IFS=', '; echo "${DETECTED[*]}")
  echo "$(date -u +%FT%TZ) $HOOK BLOCKED: $LABELS" >> "$LOG"
  echo "$HOOK BLOCKED: Prompt appears to contain credentials: $LABELS"
  echo "Remove credentials before submitting. Use environment variables or a secrets manager instead."
  exit 2
fi

exit 0
