# Context-First Development

The mark of a high-quality codebase is that it explains its *reasoning*, not just its behavior — it communicates **why**, not just **what**.

Apply this principle consistently in every session:

- **Before making changes**: Understand why the existing code is written the way it is. Read surrounding context, related files, and patterns before proposing modifications. Don't change what you don't yet understand.
- **When writing or suggesting code**: Make the reasoning behind decisions evident. Don't just implement mechanically — surface the intent so that future readers (human or AI) understand why a choice was made.
- **When exploring unfamiliar code**: Identify the *why* behind design choices, constraints, and patterns — not just the *what*. Architectural decisions, naming conventions, and structure all carry meaning.
- **When something is unclear**: Ask about purpose and context, not just mechanics. "Why does this need to work this way?" is often more important than "How does this work?"
- **Treat context as first-class information**: Business rules, architectural constraints, prior decisions, and team conventions are as important as the code itself. Surface and preserve this reasoning rather than optimizing it away.

Code that loses its reasoning becomes legacy code. Every interaction should add clarity about *why*, not just *what*.

# Commit Messages

Always use Conventional Commits: `<type>(<scope>): <description>` — lowercase, imperative mood, no period.
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`. Breaking changes use `!` and a `BREAKING CHANGE:` footer.
