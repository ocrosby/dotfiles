---
description: Creates a feature or hotfix branch, commits staged changes, pushes to remote, and opens a detailed PR against main.
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
```

**Prefix inference** (when not explicitly provided):
- `feat` commit type → `feature/<branch-name>`
- `fix` commit type → `hotfix/<branch-name>`
- anything else → `feature/<branch-name>`

An explicit `feature` or `hotfix` argument always overrides the inferred prefix.

## Workflow

### 1. Understand the Changes

- Run `git status` and `git diff` to see what's changed
- Read any relevant files needed to write an accurate commit message and PR description
- Identify the type of change: new feature, bug fix, refactor, etc.

### 2. Pre-flight: Lint Checks

Before touching git, run the project's lint/format checks. Detect what's available and run all that apply:

| Tool | Command |
|------|---------|
| ruff | `ruff check . && ruff format --check .` |
| flake8 | `flake8 .` |
| eslint | `npx eslint .` |
| golangci-lint | `golangci-lint run` |
| stylua | `stylua --check .` |
| luacheck | `luacheck .` |
| Makefile targets | `make lint` or `make check` if present |

**If any lint check fails: stop, report the failures, and do not proceed.** Tell the user what failed and ask them to fix it before running `/ship` again. Do not attempt to auto-fix lint errors unless the user explicitly asks.

### 3. Confirm Branch Name

Derive the branch prefix from the conventional commit type of the changes:

| Commit type | Branch prefix |
|-------------|---------------|
| `feat` | `feature/` |
| `fix` | `hotfix/` |
| anything else (`refactor`, `chore`, `docs`, etc.) | `feature/` |

- If the user passed `feature` or `hotfix` explicitly, use that — it overrides the inferred prefix
- Propose a full branch name (e.g., `feature/add-user-auth`, `hotfix/fix-null-pointer`)
- Ask for confirmation before proceeding

### 4. Create the Branch from Latest Main

Always branch from a fresh copy of the base branch to avoid merge conflicts:

```bash
git fetch origin
git checkout <base-branch>
git pull origin <base-branch>
git checkout -b <prefix>/<name>
```

If the user has uncommitted changes, stash them first (`git stash`), create the branch, then pop (`git stash pop`).

### 5. Stage and Commit

- Stage relevant files — prefer specific files over `git add -A`
- Write a Conventional Commit message following the Angular convention:
  - `feat`, `fix`, `docs`, `refactor`, `chore`, etc.
  - Lowercase, imperative mood, no period, under 72 characters
  - Body explains *why*, not *what*
- Commit using a HEREDOC to preserve formatting

### 6. Push to Remote

```bash
git push -u origin <branch-name>
```

### 7. Create the Pull Request

Use `gh pr create` with a structured body:

```
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
```

PR title should follow Conventional Commits format (same type/scope as the commit).

Keep the title under 70 characters.

### 8. Return the PR URL

Always output the PR URL at the end so the user can open it directly.

## Rules

- Never force-push or use `--no-verify`
- Never commit to `main` or `master` directly
- If the working tree is clean, tell the user there's nothing to ship
- If there are untracked files that seem relevant, ask whether to include them
- Use the conventional-commits rule for all commit messages
