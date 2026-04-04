---
description: Runs a structured code review of changed files covering quality, security, and architecture.
triggers:
  - /review
---

# Code Review

Use this skill when you want an explicit, structured review of changed or specified files.

## Usage

```
/review                    # review all files changed since last commit
/review <file-or-glob>     # review specific files
/review HEAD~3             # review all changes in the last 3 commits
```

## Workflow

### 1. Identify the Scope

If no argument is given, run `git diff --name-only HEAD` to find changed files.
If an argument is given, use it as the file list or pass it to `git diff --name-only <ref>`.

Read each file in scope.

### 2. Detect the Language

Route the review to the appropriate language-specific criteria based on file extension:

| Extension | Criteria |
|---|---|
| `.go` | Go conventions, error handling, concurrency, architecture |
| `.py` | Python conventions, type hints, domain boundaries, FastAPI patterns |
| `.lua` | Neovim API usage, idiomatic Lua, plugin structure |
| `.feature` | BDD best practices, declarative steps, scenario independence |
| Other | General quality, security, readability |

### 3. Review Each File

For each file, check the following dimensions:

#### Correctness
- Logic errors, off-by-one, nil/None handling
- Error paths that are silently swallowed
- Incorrect assumptions about external state

#### Security (OWASP Top 10 focus)
- Injection: SQL, command, template, path traversal
- Authentication/authorization gaps
- Sensitive data in logs, error messages, or responses
- Insecure deserialization or untrusted input passed to dangerous functions

#### Architecture
- Does the change respect layer boundaries (domain vs adapter vs infrastructure)?
- Are dependencies going in the right direction?
- Is new complexity justified by the problem, or is it speculative?

#### Quality
- Naming clarity — does the name communicate intent?
- Functions doing more than one thing
- Duplication that should be extracted (Rule of Three)
- Dead code or commented-out code left behind

#### Test Coverage
- Are new behaviors covered by tests?
- Are edge cases and error paths tested?
- Are tests testing behavior, not implementation?

### 4. Report

Structure the report as:

```
## Review: <filename>

### Must Fix
- <issue> — <why it matters> (line N)

### Should Fix
- <issue> — <why it matters> (line N)

### Consider
- <suggestion> — <trade-off> (line N)
```

**Must Fix** — correctness bugs, security issues, broken contracts
**Should Fix** — quality issues that will cause problems at scale
**Consider** — style, naming, optional improvements

If a file has no issues, write: `✓ <filename> — no issues found`

### 5. Summary

After reviewing all files, write a one-paragraph summary:
- Overall assessment (ready to ship / needs work / significant concerns)
- The most important issue if any
- Any cross-cutting pattern across files worth noting

## Rules

- Report issues with file and line number when possible
- Distinguish between blocking issues and suggestions — not everything is a Must Fix
- Do not rewrite code unless the user asks; describe what to change and why
- If a pattern appears in multiple files, call it out as a systemic issue rather than repeating the same comment
