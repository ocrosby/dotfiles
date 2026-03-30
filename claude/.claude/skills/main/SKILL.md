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
3. Delete merged local branches: `git branch --merged main | grep -v '^\*\|main\|master' | xargs -r git branch -d`
4. Report the result — current branch, the pull output (fast-forward, already up to date, etc.), and any branches that were deleted

## Rules

- If there are uncommitted changes on the current branch, warn the user before switching and ask whether to stash, commit, or abort
- If `main` does not exist but `master` does, use `master` instead
- Always report the final state: current branch and whether the pull brought in new commits
- If no merged branches were found to delete, omit that from the report (don't mention it)
