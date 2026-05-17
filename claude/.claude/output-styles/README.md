# Output Styles

Output styles are Markdown files that define a named formatting persona Claude adopts when asked to respond in that style. They let you switch Claude's response format — structure, tone, verbosity, and conventions — for a specific context without rewriting rules or prompts.

## When to use an output style

Use an output style when you want Claude to consistently format responses in a way that doesn't make sense as an always-on rule — for instance, generating a specific report format, writing in a particular documentation style, or producing output that will be piped into another tool.

| Use an output style when... | Use a rule instead when... |
|---|---|
| The format is context-specific and opt-in | The format should apply to every session automatically |
| You need different formats for different audiences | One format fits all work in this project |
| The style affects structure, not just tone | The behavior is about what Claude does, not how it writes |

## File format

An output style is a plain Markdown file named after the style:

```
output-styles/
  brief.md        →  "respond in brief style"
  incident.md     →  "respond in incident style"
  standup.md      →  "respond in standup style"
```

The file content is the formatting specification Claude follows when that style is active. There is no frontmatter — the entire file is instruction prose.

### Example: `standup.md`

```markdown
# Standup Style

Format every response as a standup update with three sections:

**Yesterday:** bullet list of completed items
**Today:** bullet list of planned items
**Blockers:** bullet list of blockers, or "None"

Keep each bullet under 15 words. No prose outside these three sections.
```

### Example: `incident.md`

```markdown
# Incident Response Style

Format responses as structured incident updates:

**Status:** [Investigating | Identified | Monitoring | Resolved]
**Impact:** one sentence describing what is affected
**Timeline:** bullet list of events with timestamps
**Next action:** what happens next and who owns it

Use precise technical language. No speculation — if unknown, say so explicitly.
```

## Invoking a style

Reference the style file by name when starting a task:

> "Using the standup style, summarize what I've done today."

> "Write this up in incident style."

Or instruct Claude to load the style file directly:

> "Read `output-styles/brief.md` and use that format for your responses this session."

## Adding a new style

1. Create a Markdown file in this directory named after the style
2. Write the formatting specification as instruction prose — be explicit about structure, length, and conventions
3. Test it by asking Claude to respond using that style on a sample input
