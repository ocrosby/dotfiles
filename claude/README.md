# Claude Code Configuration

This stow package manages global Claude Code configuration files symlinked into `~/.claude/`.

## When to Use What

### Rules (`rules/`)

Use a rule when you want Claude to **always follow a convention** without being asked.

- Loaded automatically at session start (or when a matching file enters context if `paths:` is set)
- Best for: coding standards, commit formats, naming conventions, style guides
- Think of rules as "background instructions" — they shape behavior passively

### Skills (`skills/`)

Use a skill when you have a **repeatable workflow** you want to invoke on demand with `/skill-name`.

- Each skill is a directory with a `SKILL.md` and optional supporting files
- Best for: code review checklists, deployment workflows, PR templates, scaffolding
- Can accept arguments (e.g., `/deploy staging`)
- Can be restricted to user-only invocation with `disable-model-invocation: true`

### Agents (`agents/`)

Use an agent when a task needs **isolation** — its own context window, restricted tools, or a different model.

- Runs in a separate context window from your main session
- Best for: code review (read-only), security audits, specialized analysis
- Use `tools:` frontmatter to restrict what the agent can do (e.g., read-only access)
- Invoked by Claude automatically based on `description`, or manually with `@agent-name`

### Commands (`commands/`)

Use a command when you want a **simple, single-file prompt** invoked with `/command-name`.

- Same as a skill but without supporting files — just one markdown file
- Best for: lightweight prompts that don't need bundled references
- Prefer skills for anything complex; commands are the simpler alternative

### Output Styles (`output-styles/`)

Use an output style when you want to **change how Claude responds** across an entire session.

- Appended to the system prompt at session start
- Best for: teaching mode, verbose explanations, terse responses, non-coding use cases
- Selected via `outputStyle` in `settings.json`

## Quick Reference

| I want Claude to... | Use a... |
|---|---|
| Always follow a convention | Rule |
| Run a workflow when I ask | Skill |
| Delegate a task with restricted access | Agent |
| Run a simple prompt when I ask | Command |
| Change its response style globally | Output Style |

## Current Configuration

### Rules

| Rule | Scope | Description |
|---|---|---|
| `conventional-commits.md` | All files | Enforces Conventional Commits with Angular types (`feat`, `fix`, `docs`, etc.) |
| `python-conventions.md` | `*.py`, `pyproject.toml`, `uv.lock` | Python standards: DRY/SOLID/CLEAN, rule of three, GoF patterns, DI, type hints, pytest + pytest-mock, uv, click for CLIs, hexagonal architecture for servers |

### Skills

| Skill | Auto-invoked | Description |
|---|---|---|
| `test-driven-development/` | Yes | Enforces red-green-refactor TDD cycle. Bundles `testing-anti-patterns.md` as a reference for common mocking and testing mistakes |

## References

- [Claude Code Documentation](https://code.claude.com/docs/en/overview) — Official Claude Code docs covering configuration, skills, rules, agents, and more
- [obra/superpowers](https://github.com/obra/superpowers) — Community collection of Claude Code skills, rules, and agents. The TDD skill was adapted from here.
