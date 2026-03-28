---
paths:
  - "**"
---

# Conventional Commits (Angular Standard)

When creating git commits, always use the Conventional Commits specification with Angular convention types.

## Format

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

## Types

- **feat**: new feature (MINOR version bump)
- **fix**: bug fix (PATCH version bump)
- **docs**: documentation only
- **style**: formatting, whitespace, semicolons (no code change)
- **refactor**: code change that neither fixes a bug nor adds a feature
- **perf**: performance improvement
- **test**: adding or correcting tests
- **build**: build system or external dependencies
- **ci**: CI configuration and scripts
- **chore**: maintenance tasks that don't modify src or test files

## Rules

- Description must be lowercase, imperative mood, no period at the end
- Scope is optional but encouraged when the change targets a specific area
- Breaking changes must include `!` after the type/scope and a `BREAKING CHANGE:` footer
- Body should explain the "why", not the "what"
- Keep the subject line under 72 characters
