# My dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

Ensure you have the following installed on your system:

```shell
brew install git stow
```

## Installation

Clone the repo into your `$HOME` directory:

```shell
git clone https://github.com/ocrosby/dotfiles ~/dotfiles
```

Use GNU Stow to create symlinks:

```shell
cd ~/dotfiles
stow */
```

> **Note:** The trailing `/` after `*` is required for stow to work correctly.

## What's Included

| Directory | Description |
|-----------|-------------|
| `bin/`    | Custom shell scripts (`gateway`, `ipaddr`, `reset-wifi`, `update`, etc.) |
| `claude/` | [Claude Code](https://code.claude.com) global configuration |
| `config/` | XDG config files |
| `shell/` | Vim essentials |
| `tmux/`  | Tmux Plugin Manager (TPM) |

## Claude Code

The `claude/` package manages global Claude Code configuration files symlinked into `~/.claude/`.

### Managed files

| File/Directory | Purpose |
|----------------|---------|
| `settings.json` | Default permissions, hooks, and model preferences |
| `rules/` | User-level rules loaded at session start or by file path |
| `skills/` | Reusable prompt workflows available in every project |
| `commands/` | Single-file commands available in every project |
| `agents/` | Custom subagents available in every project |
| `output-styles/` | Custom output style definitions |

### Adding configuration

Edit files directly in `~/dotfiles/claude/.claude/` — they are already symlinked into `~/.claude/`. For example:

```shell
# Add a global CLAUDE.md with personal preferences
vim ~/dotfiles/claude/.claude/CLAUDE.md

# Add a custom keybindings file
vim ~/dotfiles/claude/.claude/keybindings.json

# Add a rule
vim ~/dotfiles/claude/.claude/rules/my-conventions.md

# Add a skill
mkdir ~/dotfiles/claude/.claude/skills/my-skill
vim ~/dotfiles/claude/.claude/skills/my-skill/SKILL.md
```

> **Note:** Auto-generated directories like `projects/`, `sessions/`, and `cache/` are managed by Claude Code itself and are not stowed.

## References

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs)
