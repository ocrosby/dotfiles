---
description: Generates living documentation from Gherkin feature files as readable Markdown summaries.
triggers:
  - /gherkin-docs
paths:
  - "**/*.feature"
---

# Gherkin Documentation Writer

Use this skill to generate human-readable documentation from feature files — useful for sharing test coverage with non-technical stakeholders, building a product spec, or auditing what behaviors are actually tested.

## Usage

```
/gherkin-docs                        # document all feature files
/gherkin-docs <path>                 # document a specific file or directory
/gherkin-docs --summary              # one-line-per-feature summary only
```

## Workflow

### 1. Discover Feature Files

```bash
find . -name "*.feature" -not -path "*/node_modules/*" -not -path "*/.venv/*"
```

Group files by directory — each directory typically represents a domain area.

### 2. Parse Each Feature File

For each `.feature` file, extract:
- Feature title and description
- Background steps (shared preconditions)
- Each scenario title and its Given/When/Then steps
- Scenario Outline tables
- Tags (used to indicate scope, environment, or criticality)

### 3. Generate Documentation

Produce a Markdown document structured as:

```markdown
# Feature Coverage

> Generated from {N} feature files across {M} domain areas.

---

## {Domain Area}

### {Feature Title}

> {Feature description if present}

| Scenario | Tags | Steps |
|---|---|---|
| {Scenario name} | `@smoke` `@auth` | Given ... / When ... / Then ... |
| {Scenario name} | — | Given ... / When ... / Then ... |

**Background:** {Background steps if present}

---
```

For Scenario Outlines, show one representative row and note "N variants" rather than expanding every example.

### 4. Add a Coverage Summary

At the top of the document, include:

```markdown
## Summary

| Domain | Features | Scenarios | Smoke |
|---|---|---|---|
| auth | 3 | 14 | 5 |
| users | 2 | 9 | 3 |
| **Total** | **5** | **23** | **8** |
```

### 5. Output

Write the output to `docs/features.md` (or a path specified by the user). If `docs/` doesn't exist, create it.

Confirm the output path before writing.

## Rules

- Do not modify feature files — this skill is read-only except for writing the output doc
- If a feature file has no description, use the file path as context for grouping
- Keep scenario step summaries short — truncate at 80 characters if needed
- Preserve the order of features as they appear in the file system
- Flag scenarios with no tags as potentially uncategorized
- If `@wip` or `@skip` tags are found, call them out in the summary as excluded scenarios
