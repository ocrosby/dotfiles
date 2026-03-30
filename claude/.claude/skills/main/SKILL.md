---
description: Checks out the main branch and pulls the latest changes from remote.
triggers:
  - /main
---

# Main: Checkout and Pull Latest

Use this skill when the user wants to switch to the main branch and sync it with the remote.

## Workflow

1. Run `git checkout main`
2. Run `git pull origin main`
3. Report the result — current branch and the pull output (fast-forward, already up to date, etc.)

## Rules

- If there are uncommitted changes on the current branch, warn the user before switching and ask whether to stash, commit, or abort
- If `main` does not exist but `master` does, use `master` instead
- Always report the final state: current branch and whether the pull brought in new commits
