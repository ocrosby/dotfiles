# Session Startup: Read Project Markdown

At the start of every new session, before responding to any task, use the Glob tool to find all `**/*.md` files in the current working directory. Read the ones that appear relevant to understanding the project — prioritize `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `docs/`, and any top-level markdown files. This gives you the reasoning and context behind the codebase before you begin working.

**Exclude** markdown files from dependency/install directories: `node_modules`, `.git`, `dist`, `build`, `.claude`, `site-packages`, `.venv`, `venv`, `env`, `.tox`, `__pycache__`.

**Exception**: Always include markdown from these internal packages even if they appear inside a dependency directory:
- `sun-qa-python-tools`
- `sun-devops-python-tools`
- `sun-qa-data`
- `sun-gis-python-tools`

If the working directory is `~/.claude` or a non-project directory, skip this step.
