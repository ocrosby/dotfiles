---
description: Audits all existing Claude skill files for structural quality, language durability, and consistency with rules and agents. Produces a prioritized findings report.
triggers:
  - /skill-audit
---

# Skill Audit

Use this skill to health-check all existing skills at once — after inheriting a configuration, before a major refactor, or when skills feel inconsistent. It runs the `skill-reviewer` agent on every skill and compiles a prioritized report.

## Usage

```
/skill-audit              # audit all skills/*/SKILL.md files
/skill-audit <name>       # audit a single skill by name
```

## Workflow

### 1. Discover skill files

```bash
find ~/.claude/skills -name "SKILL.md" | sort
```

If a skill name was provided, filter to that file only.

### 2. Run skill-reviewer on each file

For each skill file found, invoke the `skill-reviewer` agent with the file path. Collect all findings.

### 3. Compile the report

Organize findings into three sections:

#### Critical (must fix before next use)

List skills with findings that will cause them to not work, be ignored, or create cycles. For each:

```
**skills/<name>/SKILL.md**
- <finding>
- <finding>
```

#### Warnings (should fix — will drift)

List skills with findings that will produce inconsistent behavior across sessions.

#### Suggestions (optional improvements)

List skills with minor quality improvements worth making.

### 4. Prioritize

After the full report, write a **Top 3 to fix now** section: the three skills whose issues are most likely to affect current work or cause immediate cycles.

### 5. Optionally fix in place

If the user asks to fix issues found:

- Fix Critical findings immediately, one skill at a time
- Confirm each fix with the `skill-reviewer` agent before moving to the next
- Commit after each skill is clean: `fix(claude): resolve skill-audit findings in /<skill-name>`

Do not batch multiple skills into one commit — it makes it harder to revert a bad fix.

## Rules

- Do not skip any skill file found in step 1 — a partial audit is misleading
- Do not auto-fix without confirming with the user first
- Report findings even if the skill is rarely used — silent debt accumulates
