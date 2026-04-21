---
description: Reports the current working directory with project context — language, type, and git status.
triggers:
  - /dir
  - /pwd
---

# Dir: Working Directory Report

Use this skill when you need a quick orientation snapshot of where you are and what kind of project you are in.

## When to use

Invoke `/dir` at the start of a session, when switching contexts, or any time you need a concise summary of the current working directory.

Do not invoke on individual file paths — this skill reports on the current directory as a whole.

## Workflow

### 1. Capture the Path

Run `pwd` and record the absolute path.

### 2. Detect Project Type

Check for these marker files in the current directory (in order):

| Marker | Project type |
|---|---|
| `go.mod` | Go module |
| `pyproject.toml` / `setup.py` | Python package |
| `package.json` | Node.js / JavaScript |
| `Cargo.toml` | Rust |
| `*.rockspec` or `lua/` | Lua / Neovim plugin |
| `CLAUDE.md` or `.claude/` | Claude configuration |
| None of the above | General directory |

### 3. Report Git Context

Run `git status --short --branch 2>/dev/null` to get the current branch and dirty state. If the directory is not a git repository, note that explicitly.

### 4. Deliver the Report

Output the report in this exact format:

```
**Directory:** <absolute path>
**Project:** <type from step 2>
**Branch:** <branch name>

Modified files:
  M path/to/changed-file.go
  ?? path/to/untracked-file.go
```

If there are no modified or untracked files, replace the file list with `(clean)`.

If not in a git repo, omit the Branch line and the modified files section.

### 5. Verify

Confirm the reported path matches `pwd` output exactly before responding. Do not report a cached or assumed path.
