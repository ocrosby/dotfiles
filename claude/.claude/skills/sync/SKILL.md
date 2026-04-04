---
description: Rebases the current feature branch onto the latest main, handling stash and conflict guidance.
triggers:
  - /sync
---

# Sync: Rebase Feature Branch onto Main

Use this skill to bring a feature branch up to date with the latest main without merging.

## Usage

```
/sync              # rebase current branch onto main
/sync <base>       # rebase current branch onto a different base (e.g. /sync develop)
```

## Workflow

### 1. Check Current State

```bash
git status
git branch --show-current
```

- If already on `main` or `master`: tell the user to use `/main` instead and stop
- Record the current branch name for the report

### 2. Stash Uncommitted Changes (if any)

If `git status` shows uncommitted changes:

```bash
git stash push -m "sync: stash before rebase"
```

Remember to pop the stash after rebase completes.

### 3. Fetch and Rebase

```bash
git fetch origin
git rebase origin/main
```

If a different base was specified, use that instead of `origin/main`.

### 4. Handle Conflicts

If the rebase stops with conflicts:

1. Report which files have conflicts and show the conflicting hunks
2. Explain the conflicting changes on each side (what main changed vs what the branch changed)
3. Do **not** automatically resolve conflicts — present the options and ask the user how to resolve each one
4. Once the user resolves, run `git rebase --continue` and repeat for the next conflict
5. If the user wants to abort: `git rebase --abort`

### 5. Pop Stash (if stashed)

After a successful rebase:

```bash
git stash pop
```

If the stash pop produces conflicts, report them the same way as rebase conflicts.

### 6. Report

On success, report:
- Current branch name
- How many commits were rebased
- Whether changes were stashed and restored
- The new base commit (first line of `git log origin/main -1 --oneline`)

### 7. Run Tests

After a clean rebase where commits were actually applied (not "already up to date"), suggest running the test suite:

```bash
go test ./...   # Go
pytest          # Python
```

A rebase that applies without conflicts can still introduce logic-level breakage where your changes and main's changes interact incorrectly. Tests are the only way to catch this.

## Rules

- Never use `git merge` — always rebase to keep a linear history
- Never force-push unless the user explicitly asks (`git push --force-with-lease` is safer if they do)
- If `main` does not exist but `master` does, use `master`
- If the branch is already up to date, report that and stop — do not create an empty rebase
- Always pop the stash even if the rebase fails, so the user's work is not lost
