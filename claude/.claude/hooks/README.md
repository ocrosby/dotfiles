# Hooks

Hooks are shell scripts that Claude Code executes automatically at specific lifecycle events. They run outside of Claude's context — the harness executes them directly — which means they can enforce behaviors that rules and memory cannot guarantee.

## When to use a hook

Use a hook when you need **guaranteed enforcement**, not just guidance. Rules and memory ask Claude to behave a certain way; hooks make behavior happen regardless of what Claude decides.

| Use a hook when... | Use a rule/skill instead when... |
|---|---|
| A behavior must never be skipped (e.g., block a push to main) | You want to guide Claude's reasoning or defaults |
| An external tool must run after every file edit (e.g., lint) | The behavior is advisory or context-dependent |
| You need to inject context Claude can't observe itself | The check only matters some of the time |
| You want to block a dangerous action before it executes | The behavior involves judgment or nuance |

Hooks remind, warn, or block — but Claude still sees their output and can respond to it. A hook that exits non-zero shows a warning; exit 2 hard-blocks the action.

## Hook event types

| Event | When it fires | Common uses |
|---|---|---|
| `PreToolUse` | Before a tool call executes | Block dangerous actions, warn before sensitive reads, remind before edits |
| `PostToolUse` | After a tool call completes | Lint edited files, validate commit messages |
| `UserPromptSubmit` | When the user submits a prompt | Scan prompts for credentials before Claude sees them |
| `PreCompact` | Before context compaction | Inject repo state into the compaction summary |
| `Stop` | When Claude finishes a response | Log session boundaries |

## Exit codes

| Exit code | Effect |
|---|---|
| `0` | Allow the action; any stdout is injected as context for Claude |
| Non-zero | Show a warning to Claude; Claude can decide how to respond |
| `2` | Hard-block: the action is cancelled and Claude is told it was blocked |

## Hooks in this directory

| Hook | Event | Matcher | Purpose |
|---|---|---|---|
| `protect-main.sh` | PreToolUse | `Bash(git commit:*)`, `Bash(git push:*)` | Blocks direct commits and pushes to `main`/`master` |
| `conflict-check.sh` | PreToolUse | `Bash(git push:*)` | Warns when branch files overlap with `origin/main` changes — suggests rebase before push |
| `tdd-remind.sh` | PreToolUse | `Edit\|Write` | Reminds Claude to follow the TDD red-green-refactor cycle before editing code files |
| `sensitive-file-warn.sh` | PreToolUse | `Read` | Warns before reading `.env`, credentials, or key files so Claude avoids echoing secrets |
| `lint.sh` | PostToolUse | `Edit\|Write` | Runs the appropriate linter (ruff, golangci-lint, luacheck) after every file edit |
| `commit-msg.sh` | PostToolUse | `Bash(git commit:*)` | Validates that commit messages follow Conventional Commits format |
| `secret-scan.sh` | UserPromptSubmit | _(all prompts)_ | Scans user prompts for credential patterns and hard-blocks (exit 2) if found |
| `pre-compact.sh` | PreCompact | _(all)_ | Injects current repo state into the compaction summary to preserve context |
| `session-stop.sh` | Stop | _(all)_ | Appends a turn-end marker to `hook-debug.log` for session boundary correlation |

## Adding a new hook

1. Create the script in this directory: `hooks/my-hook.sh`
2. Make it executable: `chmod +x ~/.claude/hooks/my-hook.sh`
3. Register it in `settings.json` under the appropriate event type with a `matcher`
4. Test with a dry run — check `hook-debug.log` to confirm it fires

### Minimal hook template

```bash
#!/usr/bin/env bash
set -uo pipefail

INPUT=$(cat)
# Parse what you need from $INPUT using jq

# Exit 0 to allow, non-zero to warn, 2 to hard-block
exit 0
```

The `$INPUT` JSON varies by event type — use `jq` to extract `tool_input`, `tool_name`, `prompt`, or `session_id` as needed.
