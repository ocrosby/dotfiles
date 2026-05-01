# Context-First Development

The mark of a high-quality codebase is that it explains its *reasoning*, not just its behavior — it communicates **why**, not just **what**.

Apply this principle consistently in every session:

- **Before making changes**: Understand why the existing code is written the way it is. Read surrounding context, related files, and patterns before proposing modifications. Don't change what you don't yet understand.
- **When writing or suggesting code**: Make the reasoning behind decisions evident. Don't just implement mechanically — surface the intent so that future readers (human or AI) understand why a choice was made.
- **When exploring unfamiliar code**: Identify the *why* behind design choices, constraints, and patterns — not just the *what*. Architectural decisions, naming conventions, and structure all carry meaning.
- **When something is unclear**: Ask about purpose and context, not just mechanics. "Why does this need to work this way?" is often more important than "How does this work?"
- **Treat context as first-class information**: Business rules, architectural constraints, prior decisions, and team conventions are as important as the code itself. Surface and preserve this reasoning rather than optimizing it away.

Code that loses its reasoning becomes legacy code. Every interaction should add clarity about *why*, not just *what*.

# Task Tracking

When working on complex tasks (multi-step implementations, multi-file changes, bug hunts, refactors — anything where tracking progress adds value), create a `TODO.md` file at the root of the current git repo with a checklist of planned steps. Check off items as they are completed.

Always ensure `TODO.md` is listed in the repo's `.gitignore`. If it isn't, add it as part of the first write.

# Commit Messages

Always use Conventional Commits: `<type>(<scope>): <description>` — lowercase, imperative mood, no period.
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`. Breaking changes use `!` and a `BREAKING CHANGE:` footer.

# PR Discipline

One PR = one `type(scope)` pair. Before creating a branch, committing, or pushing, ask: "Can I describe all of these changes with a single conventional commit subject line?" If the answer contains "and" — there are mixed concerns that must be split.

**When starting work:** name the branch after the intended commit (e.g. `chore/remove-junitxml`, `test/bdd-v2-steps`) before touching any files. Don't let unrelated changes accumulate on the same branch.

**When mixed concerns are detected mid-stream:**
1. Stash all uncommitted changes: `git stash push -u -m "split: <description>"`
2. Create one branch from `main` per concern
3. Apply only the relevant files to each branch from the stash
4. Each branch gets its own PR targeting `main`

**Before pushing:** run `git fetch origin main` and check whether the files you changed also changed on main since the branch diverged. If they did, rebase before opening the PR: `git rebase origin/main`.
