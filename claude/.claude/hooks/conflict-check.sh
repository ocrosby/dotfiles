#!/usr/bin/env bash
# PreToolUse hook: warn Claude when files changed on this branch also changed on
# origin/main since the branch diverged — surfaces potential merge conflicts
# before the push, so a rebase can happen first.
#
# Outputs additionalContext JSON (non-blocking) when overlap is found.
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only relevant for git push
[[ "$COMMAND" != *"git push"* ]] && exit 0

# protect-main.sh handles the main/master case; skip here
BRANCH=$(cd "${CLAUDE_PROJECT_DIR:-.}" && git branch --show-current 2>/dev/null)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Fetch silently — a stale origin/main is a false negative
git fetch origin main --quiet 2>/dev/null || exit 0

MERGE_BASE=$(git merge-base HEAD origin/main 2>/dev/null) || exit 0
[[ -z "$MERGE_BASE" ]] && exit 0

# Files this branch changed since it diverged from main
BRANCH_FILES=$(git diff --name-only "$MERGE_BASE" HEAD 2>/dev/null | sort -u)
[[ -z "$BRANCH_FILES" ]] && exit 0

# Files main changed since the branch diverged
MAIN_FILES=$(git diff --name-only "$MERGE_BASE" origin/main 2>/dev/null | sort -u)
[[ -z "$MAIN_FILES" ]] && exit 0

OVERLAP=$(comm -12 <(echo "$BRANCH_FILES") <(echo "$MAIN_FILES") 2>/dev/null)
[[ -z "$OVERLAP" ]] && exit 0

FILES_LIST=$(echo "$OVERLAP" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"additionalContext\": \"Conflict warning: the following files were also modified on origin/main since this branch diverged — $FILES_LIST — rebase before opening the PR to avoid merge conflicts: git rebase origin/main\"}}"

exit 0
