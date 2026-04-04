---
description: Enforces structural and language conventions when editing Claude skill files
paths:
  - "skills/*/SKILL.md"
---

# Skill File Conventions

When writing or editing a `skills/*/SKILL.md` file, the following conventions are mandatory. A skill that violates these will drift, contradict other configuration, or fail to enforce the behavior it describes.

## Frontmatter (required)

Every skill must have a YAML frontmatter block with:

- `description` — one sentence, specific enough to distinguish this skill from similar ones
- `triggers` — list of `/command` names, if the skill is user-invocable
- `paths` — glob patterns, if the skill fires automatically based on file context

A skill without `triggers` AND without `paths` is unreachable — add at least one.

## Language

- Use **mandatory** language: "must", "always", "never", "do not", "required"
- Do **not** use advisory language: "should", "consider", "suggest", "prefer", "when appropriate"
- Advisory language is interpreted as optional and skipped inconsistently across sessions
- Exception: use "consider" only in a clearly labeled optional/suggestion section, never in workflow steps

## Workflow structure

- Number every step: `### 1. Step Name`
- Each step must describe a concrete action, not a general principle
- Hard-stop conditions must be explicit: "**If X: stop and do not proceed.**"
- The final step must be a verification step — confirm the output is correct before the skill exits

## Scope

- Every skill must have a "When to use" section (or an equivalent opening paragraph) that states what triggers it
- Every skill that has exceptions must define them with literal examples, not category names
- If the skill delegates to an agent, name the agent explicitly

## Conflict check

- Before finalizing a skill, verify it does not duplicate what an existing rule already enforces
- If a rule covers the same ground, the skill should reference the rule rather than repeat it
- Contradictions between a skill and a rule create cycles — one will be ignored; resolve before committing
