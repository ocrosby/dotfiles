# Workflow Audit

Reads every file under `.claude/` — agents, hooks, skills, commands, rules, and `settings.json` — and reports what's suboptimal with specific fixes, grouped by category and ordered by impact.

## What it checks

- **Correctness** — rules or skills that fire in the wrong context, semantic mismatches, contradictory steps
- **Redundancy** — duplicate sources of truth, skills that duplicate agent logic, rules covered elsewhere
- **Missing Connections** — skills without agent delegation, agents without skill entry points, rules with no hook enforcement
- **Coverage Gaps** — inconsistent language coverage, hooks that miss file types in the same family
- **Discoverability** — workflows not surfaced via commands, skills or agents that solve the same problem without knowing about each other

## Usage

```
/audit
```

Run periodically after adding new skills, agents, rules, or hooks to catch integration gaps before they accumulate.

After reporting findings, the audit will ask which to implement before making any changes.
