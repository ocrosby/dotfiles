# Session Startup: Read Project Markdown

At the start of every new session, before responding to any task, read the following files from the current working directory if they exist: `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`. Also read any markdown files directly inside a `docs/` directory. This gives you the reasoning and context behind the codebase before you begin working.

Do not glob for all markdown files — read only these known locations directly.

If the working directory is `~/.claude` or a non-project directory, skip this step.
