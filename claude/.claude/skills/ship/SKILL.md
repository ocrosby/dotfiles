---
description: Creates a feature or hotfix branch, commits staged changes, pushes to remote, and opens a detailed PR against main. Supports -m to commit directly to main instead.
triggers:
  - /ship
---

# Ship: Branch → Commit → Push → PR

Use this skill when the user wants to ship work on a new branch and open a pull request.

## Usage

```
/ship                                  # infer everything from the diff, confirm before proceeding
/ship <branch-name>                    # use this name, infer prefix from commit type
/ship feature <branch-name>           # force feature/ prefix
/ship hotfix <branch-name>            # force hotfix/ prefix
/ship [feature|hotfix] <branch-name> <base-branch>  # override base branch (default: main)
/ship -m                               # commit and push directly to main — no branch, no PR
```

**Prefix inference** (when not explicitly provided):
- `feat` commit type → `feature/<branch-name>`
- `fix` commit type → `hotfix/<branch-name>`
- anything else → `feature/<branch-name>`

An explicit `feature` or `hotfix` argument always overrides the inferred prefix.

**`-m` flag**: skips branch creation, PR creation, and the branch-name confirmation step. Commits directly to `main` and pushes. Use for trivial changes (docs, config, typos) that do not need review.

## Workflow

### 0. Detect Active Ship Branch

Before anything else, run `git branch --show-current` to check the current branch.

**If `-m` was passed**: skip to the [Direct-to-Main Workflow](#direct-to-main-workflow) section — do not run steps 4, 5, 8, or 9.

- If the current branch **is** `main` or `master`, run the full workflow (steps 1–9).
- If the current branch is **not** `main` or `master`, determine the state of the remote branch before proceeding:

#### Remote branch state check

```bash
git fetch origin
```

Then check whether the remote branch exists and whether it has been merged:

```bash
# Does the remote branch exist?
git ls-remote --exit-code origin <current-branch>

# Has it been merged into the base branch (main/master)?
git branch -r --merged origin/main | grep "origin/<current-branch>"
```

**Case A — Remote branch exists and has NOT been merged:**

The branch is still active. Skip steps 4 and 5.
Proceed directly from step 3 (tests) to step 6 (stage and commit) on the existing branch.
After pushing, check whether a PR already exists with `gh pr view --json url 2>/dev/null`.
If one exists, output its URL — do not open a new PR.

**Case B — Remote branch has already been merged (or no longer exists on remote):**

The previous branch's work is already in main. The local branch is stale.
Do not commit to it. Instead:
1. Stash any uncommitted changes: `git stash`
2. Checkout and update main: `git checkout main && git pull origin main`
3. Pop the stash: `git stash pop`
4. Inform the user: "Branch `<name>` was already merged — starting fresh from main."
5. Run the full workflow (steps 1–9) to create a new branch.

**Case C — Remote branch does not exist yet (first push on a new local branch):**

Treat as an active ship session same as Case A — skip steps 4 and 5, commit and push.
After pushing (`git push -u origin <branch>`), run `gh pr create` to open a new PR.

### 1. Understand the Changes

- Run `git status` and `git diff` to see what's changed
- Read any relevant files needed to write an accurate commit message and PR description
- Identify the type of change: new feature, bug fix, refactor, etc.

### 1.5. Group Changes into PRs

Analyze whether the working-tree changes span multiple conceptual areas. A group is a set of files that share the same intent and a single conventional-commit type+scope.

**Split signals** — treat these as separate groups:
- Different commit types (e.g., `feat` vs `fix` vs `docs` vs `chore`)
- Different scopes within the same type (e.g., `feat(auth)` vs `feat(api)`)
- Files that are logically unrelated (e.g., a new CLI flag + an unrelated bug fix + doc updates)
- Changes in independent modules that have no runtime dependency on each other

**Keep together** — do NOT split when:
- All changed files implement the same feature end-to-end (handler + model + test for one feature)
- A fix and its test live in the same scope
- A refactor touches multiple files but has a single unified intent

**If a single group covers all changes**, proceed as one PR (existing behavior).

**If multiple groups are identified**, present the proposed split to the user:

```
I found 3 conceptual groups in the working tree. I'll ship them as separate PRs:

  1. feat(auth): add OAuth2 token refresh  →  feature/add-oauth2-token-refresh
     Files: internal/auth/token.go, internal/auth/token_test.go

  2. fix(api): correct 404 on missing resource  →  hotfix/fix-404-on-missing-resource
     Files: internal/api/handler.go

  3. docs: update README with new auth flow  →  feature/update-readme-auth-flow
     Files: README.md

Proceed with all 3, or adjust the grouping?
```

Wait for explicit user confirmation before proceeding. The user may regroup, merge, or drop entries.

Once confirmed, process each group sequentially through steps 2–9. For each group:
- Stage **only the files in that group** — never `git add -A` across groups
- Create its own branch from the latest `main`
- Commit, push, and open a PR for that group
- Report the PR URL before starting the next group

### 2. Pre-flight: Lint

Before touching git, run the project's lint/format checks. Detect what's available and run all that apply:

| Tool | Command |
|------|---------|
| uv lockfile | If `uv.lock` exists: run `uv lock` to sync it, then **always** run `git add uv.lock` — even if `uv lock` produced no new changes, because the file may already carry an unstaged modification from a prior sync that must be included in the commit |
| ruff | `ruff check . && ruff format --check .` |
| flake8 | `flake8 .` |
| eslint | `npx eslint .` |
| golangci-lint (single module) | `golangci-lint run ./...` |
| golangci-lint (Go workspace) | If `go.work` exists: `find . -name "go.mod" -not -path "*/vendor/*" \| while read f; do (cd "$(dirname "$f")" && golangci-lint run ./...) \|\| exit 1; done` |
| stylua | `stylua --check .` |
| luacheck | `luacheck .` |
| Taskfile | `task lint` if `Taskfile.yml` present — preferred over raw commands in monorepos |
| Makefile targets | `make lint` or `make check` if present |

**Go workspace detection**: Before running `golangci-lint run ./...`, check for `go.work` in the repository root. If present, the repo is a Go workspace and `./...` from the root will fail — you must iterate per-module. Prefer `task lint` if a `Taskfile.yml` is present, since it already encodes the correct per-module iteration.

**If any lint check fails: stop, report the failures, and do not proceed.** Tell the user what failed and ask them to fix it before running `/ship` again. Do not attempt to auto-fix lint errors unless the user explicitly asks.

### 3. Pre-flight: Tests

Run the project's test suite. Detect what's available and run all that apply:

| Tool | Command |
|------|---------|
| Go (single module) | `go test ./...` |
| Go (workspace) | If `go.work` exists: `find . -name "go.mod" -not -path "*/vendor/*" \| while read f; do (cd "$(dirname "$f")" && go test ./... -race -count=1) \|\| exit 1; done` |
| Python | `pytest` |
| Node.js | `npm test` |
| Lua/Neovim | `make test` or `busted` if present |
| Taskfile | `task test` if `Taskfile.yml` present — preferred in monorepos |
| Makefile | `make test` if target exists |

**If any tests fail: stop, report the failures, and do not proceed.** The user must fix failing tests before shipping. Do not open a PR with a broken test suite.

### 4. Confirm Branch Name

Derive the branch prefix from the conventional commit type of the changes:

| Commit type | Branch prefix |
|-------------|---------------|
| `feat` | `feature/` |
| `fix` | `hotfix/` |
| anything else (`refactor`, `chore`, `docs`, etc.) | `feature/` |

- If the user passed `feature` or `hotfix` explicitly, use that — it overrides the inferred prefix
- Propose a full branch name (e.g., `feature/add-user-auth`, `hotfix/fix-null-pointer`)
- Ask for confirmation before proceeding — **always end the message with an explicit prompt such as: "Confirm this branch name to proceed, or suggest an alternative."** The user must not have to guess that you are waiting.

### 5. Create the Branch from Latest Main

Always branch from a fresh copy of the base branch to avoid merge conflicts:

```bash
git fetch origin
git checkout <base-branch>
git pull origin <base-branch>
git checkout -b <prefix>/<name>
```

If the user has uncommitted changes, stash them first (`git stash`), create the branch, then pop (`git stash pop`).

### 6. Stage and Commit

- Stage relevant files — prefer specific files over `git add -A`
- Write a Conventional Commit message following the Angular convention:
  - `feat`, `fix`, `docs`, `refactor`, `chore`, etc.
  - Lowercase, imperative mood, no period, under 72 characters
  - Body explains *why*, not *what*
- Commit using a HEREDOC to preserve formatting

### 7. Push to Remote

```bash
git push -u origin <branch-name>
```

### 8. Create the Pull Request

Use `gh pr create` with a structured body. Always assign the PR to the committer and label it based on the commit type:

| Commit type | Label |
|-------------|-------|
| `feat` | `enhancement` |
| `fix` | `bug` |
| `docs` | `documentation` |
| anything else | omit `--label` |

```bash
gh pr create --assignee @me --label <label> --title "..." --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Motivation
<Why this change is needed — business context, bug impact, or technical debt being addressed>

## Changes
- <specific change 1>
- <specific change 2>

## Test Plan
- [ ] <test step 1>
- [ ] <test step 2>
EOF
)"
```

PR title should follow Conventional Commits format (same type/scope as the commit).

Keep the title under 70 characters.

### 9. Return the PR URL

Always output the PR URL at the end so the user can open it directly.

## Direct-to-Main Workflow

**Only run this section when `-m` is passed. Skip it otherwise.**

### M1. Ensure on Main

```bash
git branch --show-current
```

If not already on `main` or `master`:

```bash
git stash
git checkout main && git pull origin main
git stash pop
```

### M2. Lint and Tests

Run Steps 2 and 3 exactly as in the standard workflow. **If either fails: stop and do not commit.**

### M3. Stage and Commit

Stage relevant files and write a Conventional Commit message (same rules as Step 6).

```bash
git add <files>
git commit -m "..."
```

### M4. Push to Main

```bash
git push origin main
```

Report the pushed commit hash and message. Do not open a PR.

---

## Rules

- Never force-push or use `--no-verify`
- Without `-m`: never commit to `main` or `master` directly
- With `-m`: commit directly to `main` — no branch, no PR
- If the working tree is clean, tell the user there's nothing to ship
- If there are untracked files that seem relevant, ask whether to include them
- Use the conventional-commits rule for all commit messages
- If the current branch is active and unmerged, always commit to it — never create a new branch
- If the current branch has already been merged into main, check out main and start a fresh branch — never commit to a merged branch
- In multi-PR mode, always branch each group from the latest `main` — never base one group's branch on another group's branch
- In multi-PR mode, never stage files from a different group — one group's files must not appear in another group's commit
- Lint and tests must pass before the first group is committed; do not re-run them between groups unless a group's files include build or config changes that could affect them
- `-m` always ships as a single commit to main regardless of how many groups are detected — multi-PR grouping does not apply
