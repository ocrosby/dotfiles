---
description: Designs application architecture by delegating to the appropriate language-specialist architect agent.
triggers:
  - /architect
---

# Architect

Use this skill when starting a new project, planning a significant new module, evaluating a structural redesign, or reviewing whether the current design is sound.

## Usage

```
/architect              # detect language from context and invoke appropriate agent
/architect go           # force Go architect
/architect py           # force Python architect
/architect nvim         # force Neovim plugin architect
/architect gherkin      # force Gherkin/BDD architect
```

## Workflow

### 1. Detect the Language

If no language argument is given, infer from:
- File extensions in the working directory
- `go.mod`, `pyproject.toml`, `*.rockspec`, or `*.feature` files at the root
- Ask if ambiguous

### 2. Understand the Context

Before invoking the agent, gather:
- What is the application's purpose?
- What is the entry point (HTTP server, CLI, MCP server, plugin)?
- What external dependencies exist (database, APIs, message queues)?
- What constraints apply (performance, team conventions, existing codebase)?
- Is this greenfield or a redesign of existing code?

### 3. Invoke the Architect Agent

| Language | Agent |
|---|---|
| Go | `go-architect` |
| Python | `py-architect` |
| Neovim / Lua | `nvim-architect` |
| Gherkin / BDD | `gherkin-architect` |

Pass the agent the context gathered in step 2, plus any existing code that should be analyzed.

### 4. Review the Output

The architect agent returns:
- Package/module map with responsibilities
- Dependency graph and layer boundaries
- Public API surface
- Configuration schema
- Trade-offs and alternatives considered

Review the proposal with the user before implementation begins. Architecture decisions are expensive to reverse — confirm before proceeding.

### 5. Capture Decisions

After the user approves the design:
- Document key decisions in a `ARCHITECTURE.md` or `docs/architecture.md` if one doesn't exist
- Note the *why* behind non-obvious choices — future readers need the reasoning

## Rules

- Never start implementing before the design is confirmed
- If the user asks to just start coding, recommend at least a quick 5-minute design sketch first
- For greenfield projects, always invoke the agent before writing any production code
- For redesigns, always read the existing code before invoking the agent
