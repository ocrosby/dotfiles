---
description: Audits the Claude workflow system — reads every component and reports what's suboptimal with specific fixes, grouped by category and ordered by impact.
triggers:
  - /audit
---

# Workflow Audit

## Workflow

### 1. Read Everything

Read every file under `.claude/`:

```
agents/       — all *.md agent definitions
hooks/        — all *.sh hook scripts
skills/       — all */SKILL.md skill files
commands/     — all *.md command files
rules/        — all *.md rule files
settings.json — permissions, hooks, plugins
```

Do not skip any file. The audit is only as good as the coverage.

### 2. Analyze Against Five Categories

#### Correctness
- Rules or skills that fire in the wrong context (e.g., a mandatory rule that activates during tasks it doesn't apply to)
- Semantic mismatches between a stated intent and actual behavior
- Skills whose workflow steps contradict their own rules or each other

#### Redundancy
- Duplicate sources of truth (e.g., a rule that restates what `settings.json` already enforces)
- Skills that duplicate agent logic instead of delegating to it
- Rules that repeat guidance already covered by another rule on the same paths

#### Missing Connections
- Skills that should delegate to specialist agents but do their own inline analysis instead
- Agents that have no user-invocable skill entry point
- Rules that state "never do X" with no hook to enforce it
- Skills that reference related skills/agents without linking to them

#### Coverage Gaps
- Language families with inconsistent coverage (one language has a security rule, others don't; one has a debugger agent, others don't)
- Hooks that cover some file types but not others in the same family
- Automation that would close a gap between a stated rule and its enforcement

#### Discoverability
- Workflows that exist but aren't surfaced via autocomplete, rules, or skill cross-references
- Skills or agents that solve the same problem without knowing about each other
- The `commands/` directory underused when key workflows aren't reachable via `/`

### 3. Report Findings

For each finding:

```
**[Category] Title**
What: one sentence describing the issue
Why: why it matters — what breaks or degrades without a fix
Fix: the specific change needed (file, section, what to add/remove/change)
```

Group by category. Within each group, order by impact — correctness and safety issues first, symmetry and polish last.

If no issues are found in a category, omit it from the report.

### 4. Confirm Before Implementing

After presenting all findings, ask:

> Which of these should I implement? (say "all" or list specific items)

Do not make any changes until the user confirms.

## Rules

- Read every file before reporting — partial coverage produces false confidence
- Do not report issues that were already fixed in the current session
- Distinguish clearly between "this is broken" (correctness) and "this could be better" (polish)
- If the system looks genuinely well-optimized, say so — do not manufacture findings
