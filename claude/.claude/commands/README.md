# Commands

Commands are Markdown files loaded as a prompt when the user types `/command-name` in a Claude Code session. They are the simplest invocation mechanism — no frontmatter, no step enforcement, just a document Claude reads and acts on.

## File format

A command file is plain Markdown named after the slash command it responds to:

```
commands/
  ship.md      →  /ship
  workflow.md  →  /workflow
  work.md      →  /work
```

No frontmatter is required. The filename (without `.md`) becomes the command name.

## Commands vs. skills

Both are invoked with a `/command`. The distinction is where the file lives and what structure it has:

| | Commands (`commands/`) | Skills (`skills/*/SKILL.md`) |
|---|---|---|
| Location | Flat file in `commands/` | Subdirectory with `SKILL.md` |
| Frontmatter | None required | `description`, `triggers`, `paths` |
| Auto-activation | Never — always user-invoked | Can activate via `paths` globs |
| Best for | Reference docs, complex dispatchers, multi-subcommand tools | Repeatable multi-step workflows with enforced structure |

Use a command when the content is primarily a reference document or a dispatcher that Claude reads top-to-bottom. Use a skill when the workflow has numbered steps that must be followed in order with hard-stop conditions.

## Existing commands

### `/audit`

Audits the entire `.claude/` directory — agents, hooks, skills, commands, rules, and `settings.json` — and reports what's suboptimal with specific fixes grouped by category and ordered by impact. Checks for correctness, redundancy, missing connections, coverage gaps, and discoverability issues. Asks which findings to implement before making any changes.

### `/bdd`

Runs a BDD feature file's pytest stub against a target environment and region. Parses arguments in the form `<feature_name> [--env|-e <env>] [--region|-r <region>] [--serial|-s]`, locates the feature file and corresponding test stub, runs pytest with the correct environment variables, and produces a structured results summary with per-failure detail blocks.

```
/bdd site_based_observations
/bdd time_series --env prod
/bdd historical_postal -e prod -r use1 --serial
```

### `/work`

Work journal manager. Maintains a date-structured daily log at `~/work/YYYY/M/D.md`. Carries over incomplete tasks from the previous session automatically.

| Subcommand | Description |
|---|---|
| `/work add <task>` | Add a task to today's journal |
| `/work list [period]` | List tasks for today, yesterday, this-week, or last-week |
| `/work done [task text]` | Mark a task complete |
| `/work update` | Rename a task |
| `/work note <text>` | Append a note to today's journal |

### `/workflow`

Development workflow reference. Documents the full feature workflow (`/architect` → `/*-feature` → `/code-review` → `/ship` → `/main`), branch management, maintenance commands, debugging paths, automated quality gates, and rules that fire automatically. Use this when orienting to the workflow or deciding which tool to reach for.
