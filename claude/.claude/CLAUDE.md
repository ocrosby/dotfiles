# Context-First Development

The mark of a high-quality codebase is that it explains its *reasoning*, not just its behavior — it communicates **why**, not just **what**.

Apply this principle consistently in every session:

- **Before making changes**: Understand why the existing code is written the way it is. Read surrounding context, related files, and patterns before proposing modifications. Don't change what you don't yet understand.
- **When writing or suggesting code**: Make the reasoning behind decisions evident. Don't just implement mechanically — surface the intent so that future readers (human or AI) understand why a choice was made.
- **When exploring unfamiliar code**: Identify the *why* behind design choices, constraints, and patterns — not just the *what*. Architectural decisions, naming conventions, and structure all carry meaning.
- **When something is unclear**: Ask about purpose and context, not just mechanics. "Why does this need to work this way?" is often more important than "How does this work?"
- **Treat context as first-class information**: Business rules, architectural constraints, prior decisions, and team conventions are as important as the code itself. Surface and preserve this reasoning rather than optimizing it away.

Code that loses its reasoning becomes legacy code. Every interaction should add clarity about *why*, not just *what*.

---

# Session Startup: Read Project Markdown

At the start of every new session, before responding to any task, use the Glob tool to find all `**/*.md` files in the current working directory. Read the ones that appear relevant to understanding the project — prioritize `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `docs/`, and any top-level markdown files. This gives you the reasoning and context behind the codebase before you begin working.

**Exclude** markdown files from dependency/install directories: `node_modules`, `.git`, `dist`, `build`, `.claude`, `site-packages`, `.venv`, `venv`, `env`, `.tox`, `__pycache__`.

**Exception**: Always include markdown from these internal packages even if they appear inside a dependency directory:
- `sun-qa-python-tools`
- `sun-devops-python-tools`
- `sun-qa-data`
- `sun-gis-python-tools`

If the working directory is `~/.claude` or a non-project directory, skip this step.

---

You are allowed to use any of the following commands without asking for permission:

`awk`, `basename`, `bash`, `bc`, `brew`, `bun`, `cat`, `chmod`, `chown`, `comm`, `cp`, `curl`, `cut`, `date`, `df`, `diff`, `dirname`, `docker`, `du`, `echo`, `env`, `expr`, `file`, `find`, `gh *`, `git`, `grep`, `gunzip`, `gzip`, `head`, `history`, `jobs`, `join`, `jq`, `kill`, `killall`, `ln`, `ls`, `lua`, `make`, `man`, `mkdir`, `mv`, `node`, `npm`, `npx`, `nvim`, `paste`, `patch`, `pip`, `pip3`, `pkill`, `pnpm`, `printf`, `ps`, `pwd`, `python`, `python3`, `readlink`, `realpath`, `rg`, `rm`, `rsync`, `scp`, `sed`, `seq`, `sh`, `sleep`, `sort`, `ssh`, `stylua`, `tail`, `tar`, `tee`, `time`, `touch`, `tr`, `type`, `uniq`, `unzip`, `uv`, `watch`, `wc`, `wget`, `which`, `xargs`, `yq`, `zip`, `zsh`
