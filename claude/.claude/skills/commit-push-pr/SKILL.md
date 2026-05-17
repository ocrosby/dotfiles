---
description: Commits and ships current changes. Single group → commit, push, and open a PR on the current feature branch. Multi-group → split into separate branches/PRs from main, one PR per conceptual group.
# Human gate: this skill pushes to remote and opens PRs — external, hard-to-reverse side effects.
# Block model auto-invocation; require an explicit user keystroke.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git branch *) Bash(git fetch *) Bash(git pull *) Bash(git checkout *) Bash(git stash *) Bash(git restore *) Bash(gh pr view *) Bash(gh pr create *)
---

# Commit → Push → PR

Use this skill for daily shipping. When the diff is one conceptual change, it commits on the current branch and opens a PR. When the diff spans multiple groups, it creates a fresh branch per group from `main` and opens one PR per group.

For direct-to-main commits or to trigger a patch release, use `/ship -m` or `/ship -p`.

## Usage

```
/commit-push-pr
```

No arguments. Branches, messages, and PR bodies are derived from the working tree.

## When NOT to use

- A direct-to-`main` commit is needed (trivial doc/config change, patch release) → use `/ship -m` or `/ship -p`
- A force-push or `--no-verify` commit is needed → refused; this skill never bypasses hooks or rewrites pushed history

## Workflow

### 1. Inspect state

```bash
git branch --show-current
git status --short
```

- **If the working tree is clean: stop and do not proceed.** Tell the user there is nothing to ship.

### 2. Identify conceptual groups

A *group* is a set of files that share the same intent and a single conventional-commit type + scope. Analyze the diff and classify every changed/untracked file into exactly one group.

**Split signals — treat these as separate groups:**

- Different commit types (e.g. `feat` vs `fix` vs `docs` vs `chore`)
- Different scopes within the same type (e.g. `feat(auth)` vs `feat(api)`)
- Files that are logically unrelated (a new CLI flag + an unrelated bug fix + doc updates)
- Changes in independent modules that have no runtime dependency on each other

**Keep together — do NOT split when:**

- All changed files implement the same feature end-to-end (handler + model + test for one feature)
- A fix and its test live in the same scope
- A refactor touches multiple files but has a single unified intent

If exactly one group is identified, continue at step 3. If multiple groups are identified, continue at step 4.

### 3. Single-group flow (one PR on the current branch)

- **If on `main` or `master`: stop and do not proceed.** Tell the user to switch to a feature branch, or recommend `/ship` (which creates one from a clean main).
- Stage exactly this group's files (see step 5 — staging rules apply to both flows).
- Continue at step 5 (Stage → Commit → Push → PR → Verify), staying on the current branch.

### 4. Multi-group flow (one branch + PR per group, all from latest `main`)

Present the proposed split to the user and wait for explicit confirmation before proceeding. Format:

```
Found N conceptual groups in the working tree. Proposed PRs:

  1. feat(auth): add OAuth2 token refresh  →  feature/add-oauth2-token-refresh
     Files: internal/auth/token.go, internal/auth/token_test.go

  2. fix(api): correct 404 on missing resource  →  hotfix/fix-404-on-missing-resource
     Files: internal/api/handler.go

  3. docs: update README with new auth flow  →  feature/update-readme-auth-flow
     Files: README.md

Proceed with all N, or adjust the grouping?
```

**Branch-prefix inference per group:**

| Commit type for the group | Branch prefix |
|---|---|
| `feat` | `feature/` |
| `fix` | `hotfix/` |
| anything else (`refactor`, `chore`, `docs`, etc.) | `feature/` |

Once the user confirms, process each group **sequentially**:

#### 4.1 Stash and switch to a fresh branch from `main`

On the very first group, if the working tree is dirty (which it will be), stash everything so the per-group branches start clean:

```bash
git stash push -u -m "commit-push-pr: split into PRs"
```

Then for each group:

```bash
git fetch origin
git checkout main
git pull origin main
git checkout -b <prefix>/<derived-name>
```

Restore only this group's files from the stash:

```bash
git checkout stash@{0} -- <file1> <file2> ...
```

(Or `git restore --source=stash@{0} <files>` — equivalent.)

Verify only this group's files are now modified before staging:

```bash
git status --short
```

#### 4.2 Run steps 5–8 for this group

Stage exactly this group's files, commit, push, open the PR. The single-group steps below apply unchanged.

#### 4.3 Report and move on

Print the new PR URL on its own line before starting the next group. After the last group:

```bash
git stash drop
```

If a group's branch fails its commit because changes depend on another group not yet merged, add a `Depends on #<PR-number>` line to that PR's body and continue. Never push a knowingly-broken branch without this note.

### 5. Stage relevant files

- Stage individual files explicitly — never `git add -A`. In multi-group mode, never stage files from a different group in the same commit.
- If untracked files appear to belong to the current group, confirm with the user before staging.

### 6. Commit

Write a Conventional Commit message:

- `<type>(<scope>): <description>`
- Lowercase type, imperative mood, no period, under 72 characters
- Body explains *why*, not *what*

Commit using HEREDOC to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body — the why>
EOF
)"
```

Never pass `--no-verify`. If a pre-commit hook fails, fix the underlying issue, re-stage, and commit again — never amend the previous commit and never bypass the hook.

### 7. Push

```bash
git push -u origin "$(git branch --show-current)"
```

The `-u` flag is idempotent — safe whether the upstream is already set or not. Never `--force` or `--force-with-lease`.

### 8. Open or update the PR

Check whether a PR already exists for the current branch:

```bash
gh pr view --json url --jq .url 2>/dev/null
```

- **PR exists:** output its URL — do not open a new one. The push in step 7 has already updated it.
- **No PR exists:** open one with `gh pr create`:

```bash
gh pr create --assignee @me --label <label> --title "<conventional title>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Motivation
<why — business context, bug impact, technical debt>

## Test Plan
- [ ] <test step 1>
- [ ] <test step 2>
EOF
)"
```

Label by commit type:

| Commit type | Label |
|---|---|
| `feat` | `enhancement` |
| `fix` | `bug` |
| `docs` | `documentation` |
| anything else | omit `--label` |

PR title follows the same Conventional Commits format as the commit, under 70 characters.

### 9. Verify

Confirm the change reached the remote and the PR is reachable:

```bash
git log -1 "origin/$(git branch --show-current)" --oneline
gh pr view --json url,state --jq '"\(.state) \(.url)"'
```

Output the PR URL on its own line so the user can open it directly. In multi-group mode, do this after each group so every PR URL appears in the conversation as it's created, and again as a consolidated list after the final group.

## Rules

- Never commit to `main` or `master` directly — refuse (recommend `/ship -m` if intended)
- Never `--no-verify`, never `--force` / `--force-with-lease`, never amend a pushed commit
- Single-group flow only runs when already on a feature branch; on `main` or `master` it refuses
- Multi-group flow always branches each group from the **latest** `main` — never from another group's branch
- Multi-group flow never stages files from a different group in the same commit
- Always assign every PR to `@me`
- If a PR already exists for a branch, update it via push — never open a duplicate
