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
3. If `uv.lock` exists: run `uv lock` to re-sync the lockfile with any version bump
   that the release workflow may have committed to main. Report if `uv.lock` changed.
4. Delete merged local branches using a two-pass approach:
   - **Pass 1 — fast-forward merges**: `git branch --merged main | grep -v '^\*\|main\|master' | xargs -r git branch -d`
   - **Pass 2 — squash/rebase merges**: for any branch that `-d` skipped (the error lists them), check if a PR was merged for that branch with `gh pr list --state merged --head <branch>`. If a merged PR exists, force-delete with `git branch -D <branch>`. If no merged PR exists, leave the branch alone and report it to the user.
5. Report the result — current branch, the pull output (fast-forward, already up to date, etc.), and any branches that were deleted

## Rules

- If there are uncommitted changes on the current branch, warn the user before switching and ask whether to stash, commit, or abort
- If `main` does not exist but `master` does, use `master` instead
- Always report the final state: current branch and whether the pull brought in new commits
- If no merged branches were found to delete, omit that from the report (don't mention it)
- After `uv lock`, leave `uv.lock` as an unstaged change — do not commit it automatically
