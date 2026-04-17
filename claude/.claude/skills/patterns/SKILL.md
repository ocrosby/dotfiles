---
description: Analyzes code or a problem description and recommends applicable GoF design patterns with implementation sketches grounded in the code.
triggers:
  - /patterns
---

# Pattern Advisor

Use this skill when you want to identify design pattern opportunities in existing code, choose the right pattern for a structural problem, or verify whether a pattern is being applied correctly.

## Usage

```
/patterns <file-or-glob>          # analyze specific files
/patterns                         # analyze all files changed since last commit
/patterns "describe a problem"    # recommend a pattern for a described problem
```

## Workflow

### 1. Identify Input

- If the argument is a file path or glob: read those files.
- If the argument is a quoted string: treat it as a problem description; skip to step 3.
- If no argument: run `git diff --name-only HEAD` to get changed files, then read them.

**If no files are found and no description was given: stop and ask the user what to analyze.**

### 2. Read the Code

Read each file in full. Identify the language and note the relevant idioms for that language (Go interfaces, Python Protocols, Lua module tables).

### 3. Load the Pattern Signals

Read `rules/design-patterns-application.md` for the recognition signals table.
Read `rules/design-patterns.md` for the full catalog when a specific pattern match needs validation.

### 4. Identify Pattern Signals

Scan the code (or interpret the description) for these signals. For each signal found, record:
- The exact code location (file, line number or function name)
- Which pattern it maps to
- Why (the specific structural problem present)

Signals by category (from `rules/design-patterns-application.md`):

**Creational**: constructor with 5+ parameters; `new ConcreteType()` scattered in callers; object families that must be compatible; template instances copied with variation; single shared global resource.

**Structural**: incompatible third-party interface; class growing in two dimensions; recursive tree of uniform nodes; optional combinable behaviors; complex multi-step subsystem init; thousands of similar objects; cross-cutting concerns wrapped around an object.

**Behavioral**: pipeline of handlers with dynamic order; UI action decoupled from logic + undo needed; collection traversal abstracted from structure; many components with circular dependencies; state snapshot for undo; large switch on state field; large switch on algorithm; shared algorithm skeleton with variations; new operations on a fixed hierarchy.

**If no signals are found**: skip to step 6 and report no opportunities.

### 5. Generate Recommendations

For each signal, produce one recommendation block:

```
### <Pattern Name> (<Category>)

**Signal:** <exact code location and what was observed>

**Why it fits:** <1–2 sentences on the specific structural problem this pattern solves here>

**Participants in this context:**
- <Role from pattern>: `<actual class/function/module name in the code>`
- (list all key roles)

**Sketch:**
```<language>
// minimal pseudocode showing the structural change — not a full implementation
// name the pattern participants as they would appear in the real code
```

**Trade-off:** <what applying this costs vs. what it gains in this specific context>
```

**Hard limits:**
- Never recommend more than 3 patterns per file. If more signals exist, list the top 3 by severity of current pain.
- Never recommend a pattern without citing the specific signal in the code.
- Never implement the refactoring without the user's explicit request — this skill is advisory only.

### 6. Flag Pattern Misuse

If a pattern name appears in the code (class name, comment, doc) but the implementation violates the pattern's contract, flag it separately:

```
### Misuse: <Pattern Name>

**Location:** <file and line>
**Issue:** <what the current code does that violates the pattern>
**Fix:** <what correct application requires>
```

### 7. Deliver the Report

Structure the output as:

```
## Pattern Analysis: <filename or "Problem Description">

### Opportunities
<one block per recommendation — highest-priority first>

### Misuse
<any misapplied patterns found>

### No-Pattern Zones
<note any sections that were intentionally kept simple — validate that the simplicity is appropriate>

### Summary
<one paragraph: how many signals found, highest-priority fix, and overall design health>
```

If no opportunities were found: write "No pattern opportunities identified — the current structure is appropriate for its complexity."

### 8. Confirm Before Implementing

If the user asks to implement a recommended pattern:
- Confirm the specific pattern, the participants, and the target files before writing any code.
- Delegate to the appropriate language agent for implementation: `go-architect`, `py-architect`, or `nvim-architect`.
- Do not write production code in this skill — it is analysis and recommendation only.

## Rules

- Always read the actual code before making recommendations — never recommend from the description alone when files are available.
- Distinguish between "high priority" (the current code is already painful — maintainability or testability is suffering now) and "low priority" (a future improvement with no immediate cost).
- If the user says the code is "fine as-is", accept it and close — do not push patterns onto code the user considers adequate.
