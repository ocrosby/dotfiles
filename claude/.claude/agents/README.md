# Agents

Agents are specialized Claude sub-processes launched by the main session to handle focused tasks. Each agent has its own system prompt, tool set, and permission scope — it runs in isolation and returns a single result.

## File format

Each agent is a Markdown file with a YAML frontmatter block followed by the agent's system prompt:

```markdown
---
name: agent-name
description: One-line summary used to decide when to launch this agent.
tools: Read, Grep, Glob, Bash, Write, Edit
model: claude-sonnet-4-6
permissionMode: plan
---

System prompt content here.
```

### Frontmatter fields

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Kebab-case identifier used in `Agent(subagent_type: "...")` calls |
| `description` | Yes | Shown in agent listings; used by Claude to decide which agent fits a task |
| `tools` | Yes | Comma-separated list of tools available to the agent |
| `model` | No | Defaults to the session model if omitted |
| `permissionMode` | No | `plan` (read-only, no edits without approval) or omit for full access |

### Choosing tools

Restrict tools to the minimum the agent needs. Read-only agents (reviewers, auditors) should use `Read, Grep, Glob` — adding `Edit` or `Write` would let them make changes they aren't designed to make.

## Creating a new agent

Use this prompt to create a role-based reviewer agent:

> I want to create an agent that acts as a **[role]**. It should be an expert in **[your context]** and review my work from this angle with direct feedback. Create the agent file.

**Example:**

> I want to create an agent that acts as a **security engineer**. It should be an expert in **Python backend APIs** and review my work from this angle with direct feedback. Create the agent file.

## Existing agents

| Agent | Purpose |
|---|---|
| `gherkin-architect` | Designs BDD test architecture — feature file organization, step structure, support layer |
| `gherkin-debugger` | Diagnoses and fixes bugs in Gherkin BDD test suites |
| `gherkin-reviewer` | Reviews Gherkin feature files and step definitions for BDD best practices |
| `go-architect` | Designs Go application architecture following clean architecture patterns |
| `go-debugger` | Diagnoses and fixes bugs in Go applications |
| `go-reviewer` | Reviews Go code for correctness, idiomatic patterns, and concurrency safety |
| `nvim-architect` | Designs Neovim plugin architecture and module structure |
| `nvim-debugger` | Diagnoses and fixes bugs in Neovim plugins |
| `nvim-reviewer` | Reviews Neovim plugin code for correctness and idiomatic Lua patterns |
| `py-architect` | Designs Python application architecture following hexagonal architecture principles |
| `py-debugger` | Diagnoses and fixes bugs in Python applications |
| `py-reviewer` | Reviews Python code for correctness, architecture, type safety, and idiomatic patterns |
| `rest-reviewer` | Reviews HTTP handler and route code for REST API convention compliance |
| `skill-reviewer` | Reviews Claude skill files (SKILL.md) for structural quality and consistency |
