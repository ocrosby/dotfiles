---
description: Guides creation of a new Claude skill — from purpose definition through frontmatter, workflow authoring, language audit, conflict check, and review.
triggers:
  - /skill-author
---

# Skill Author

Use this skill to create a new Claude skill file. It ensures the skill is reachable, uses durable language, has a clear workflow, and does not conflict with existing configuration.

## Usage

```
/skill-author <skill-name>         # create skills/<skill-name>/SKILL.md
/skill-author                      # prompt for skill name and purpose interactively
```

## Workflow

### 1. Define purpose and scope

Before writing anything, answer these questions:

- **What does this skill do?** One sentence, specific enough to distinguish it from existing skills.
- **What triggers it?** A user command (`/name`), a file pattern (`**/*.go`), or both?
- **What does it NOT do?** Identify the boundary so it doesn't expand into adjacent skills.
- **Does anything like this already exist?** Run: `grep -r "trigger" ~/.claude/skills/*/SKILL.md` and `grep -rl "<keyword>" ~/.claude/skills/` to check for overlap.

If an existing skill already covers this purpose, do not create a duplicate — extend or reference the existing one.

### 2. Check for rule conflicts

Search for existing rules that cover the same files or behaviors:

```bash
grep -rl "<topic>" ~/.claude/rules/
```

If a rule already enforces the behavior this skill describes, the skill must reference the rule rather than repeat it. Repeating creates drift when the rule is updated but the skill is not.

### 3. Write the frontmatter

```yaml
---
description: <one sentence — specific, not generic>
triggers:
  - /<command-name>    # include if user-invocable
paths:
  - "**/<pattern>"     # include if auto-triggered by file context
---
```

Rules:
- `description` must be specific enough to distinguish this skill from similar ones
- Include `triggers` if users invoke it with a `/command`
- Include `paths` if it fires automatically when working on certain files
- At least one of `triggers` or `paths` must be present

### 4. Write the skill title and scope section

```markdown
# Skill Name

Use this skill when <specific trigger condition>.

## When NOT to use
- <exclusion 1>
- <exclusion 2>
```

The "when not to use" section prevents the skill from being over-applied. If there are no meaningful exclusions, omit this section.

### 5. Write the workflow

Number every step. Each step must describe a **concrete action**, not a general principle.

```markdown
## Workflow

### 1. <Action verb> the <thing>

- Concrete substep
- Another substep
- **If <failure condition>: stop and do not proceed.** <What to tell the user.>

### 2. <Next action>
...

### N. Verify

Confirm the output is correct:
- <verification check 1>
- <verification check 2>
```

Requirements:
- Every blocking condition must say "**stop and do not proceed**" — not "pause" or "check with the user"
- Every step that produces output must specify what the output looks like
- The final step must be a verification or confirmation step
- If the skill delegates to an agent, name the agent explicitly

### 6. Write exceptions (if any)

Define exceptions with literal examples, not category names:

```markdown
## Exceptions

- **<Exception name>**: <exactly what qualifies — give a literal example>. Does not apply when <boundary condition>.
```

Never write: "except for mechanical changes". Always write: "except for renaming an identifier, moving a file, or updating an import path with no logic change".

### 7. Audit the language

Read through every sentence in the workflow and apply this filter:

| Advisory (rewrite) | Mandatory (keep) |
|---|---|
| should | must |
| consider | do |
| suggest | always |
| prefer | never |
| when appropriate | required |
| you may want to | do not |

Rewrite every advisory phrase as a mandatory directive or move it to an explicit "optional" callout block.

### 8. Review with skill-reviewer

Invoke the `skill-reviewer` agent on the finished file:

```
Use the skill-reviewer agent to review skills/<skill-name>/SKILL.md
```

Address all Critical and Warning findings before committing. Suggestion-level findings are optional.

### 9. Commit

```bash
git add skills/<skill-name>/SKILL.md
git commit -m "feat(claude): add /<skill-name> skill — <one-line description>"
git push
```

## Rules

- Never create a skill that duplicates an existing rule — reference the rule instead
- Never use advisory language in workflow steps
- Every exception must have a literal example
- A skill without triggers or paths is unreachable — do not commit it
- Always run the skill-reviewer agent before committing
