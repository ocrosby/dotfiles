---
description: Enforces professional structure and up-to-date workflow badges in root README.md files
paths:
  - "README.md"
---

# README Standard — Root README.md

**Every root `README.md` must conform to this standard. Do not ship a README that violates it.**

## Required Sections — In This Order

Every root `README.md` must contain all of the following H2 sections. If a section is genuinely not applicable (e.g., no configuration exists), keep the heading and write "N/A" rather than omitting it.

1. **Project title** — H1 with the repository name, followed immediately by a one-sentence description
2. **Badges** — workflow status badges (see below), license, and any relevant quality badges
3. **Table of Contents** — required when the README exceeds four sections
4. **Overview** — what the project does and why it exists; 2–5 sentences
5. **Features** — bullet list of capabilities or highlights
6. **Requirements** — runtime and tooling prerequisites with version constraints
7. **Installation** — step-by-step setup using fenced code blocks for all commands
8. **Usage** — at least one working example with output; more for complex tools
9. **Configuration** — environment variables, config files, flags, and their defaults
10. **Development** — how to set up the local dev environment, run tests, and build
11. **Contributing** — how to open issues and PRs; reference `CONTRIBUTING.md` if it exists
12. **License** — one line naming the license; reference `LICENSE` file

## Workflow Badges — Mandatory Synchronization

**Every workflow file in `.github/workflows/` must have exactly one badge in the README.** If a workflow is added or removed, the badge row must be updated in the same change.

### How to generate a badge

For each file at `.github/workflows/<filename>.yml`, the badge is:

```markdown
![<Workflow Name>](https://github.com/<owner>/<repo>/actions/workflows/<filename>.yml/badge.svg)
```

Where `<Workflow Name>` is the value of the top-level `name:` field in the workflow file.

To find the correct owner/repo, read the remote URL: `git remote get-url origin`.

### Deriving badges — required steps

When writing or updating `README.md`:

1. Run `ls .github/workflows/` to list all workflow files
2. For each file, read the `name:` field from line 1–5 of the file
3. Confirm the badge URL uses the exact filename (including `.yml` extension)
4. Verify every workflow file has a badge — no workflow may be undocumented
5. Remove any badge whose workflow file no longer exists

### Badge placement

Place all badges in a single row immediately below the H1 title, before any prose. Example:

```markdown
# my-project

One-sentence description of what it does.

![CI](https://github.com/ocrosby/my-project/actions/workflows/ci.yml/badge.svg)
![Lint](https://github.com/ocrosby/my-project/actions/workflows/lint.yml/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

## Formatting Standards

- Use H1 (`#`) for the project title only — never for sections
- Use H2 (`##`) for all required sections listed above
- Use H3 (`###`) for subsections within a required section
- All shell commands must be in fenced code blocks with a language hint: ` ```bash `, ` ```go `, ` ```python `
- No raw URLs in prose — link text must describe the destination
- No trailing whitespace on any line
- No more than one blank line between any two elements

## What "Professional" Means in Practice

- The README must be readable by someone unfamiliar with the project
- Every code example must be complete enough to copy-paste and run
- Section headings must match the actual content (no "Usage" section that only has a link)
- The badge row must not contain broken or stale badges — a badge pointing to a deleted or renamed workflow is worse than no badge
- Do not use emoji in section headings unless the project style already uses them consistently throughout

## When This Rule Triggers

This rule fires whenever `README.md` at the repository root is edited. Before finalizing any README change:

1. Confirm all required sections are present
2. Confirm badges match the current `.github/workflows/` directory exactly
3. Confirm all code blocks have language hints
4. Confirm the H1/H2/H3 hierarchy is correct
