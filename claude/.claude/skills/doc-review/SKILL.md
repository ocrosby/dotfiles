---
description: Reviews documentation files against Write the Docs principles — structure, content quality, accuracy, accessibility, and UX copy — and reports findings by severity.
triggers:
  - /doc-review
---

# Documentation Review

Reviews documentation against the principles in `rules/docs-principles.md` (sourced from writethedocs.org/guide/). Use this skill when you want an explicit audit of existing documentation rather than passive guidance during writing. If `rules/docs-principles.md` is not available in the current project context, the embedded checklist in Step 4 is self-contained and applies directly.

## When NOT to use

Do not run this skill against:
- Auto-generated documentation files (OpenAPI/Swagger JSON or YAML generated from code, godoc output, Sphinx auto-generated pages, JavaDoc)
- Files listed in `.docignore` if one exists in the repo
- Files that are intentionally stubs or work-in-progress placeholders (e.g. contain only `# TODO`)
- Vendored or third-party documentation checked in under `vendor/`, `third_party/`, or similar

## Usage

```
/doc-review                    # review all .md/.rst/.txt docs changed since last commit
/doc-review <file-or-glob>     # review specific files
/doc-review --all              # review all documentation files in the repo
/doc-review -f                 # review + automatically fix all Must Fix and Should Fix findings
/doc-review -fc                # review + fix + repeat until no findings remain
```

- `-f` — fix all Must Fix and Should Fix findings once, then stop
- `-fc` — fix, re-review, fix again, repeat until clean (implies `-f`)
- Without either flag, the skill only reports

---

## Workflow

### 1. Identify the Scope

**If no argument is given**: run `git diff --name-only HEAD` and filter for documentation files (`.md`, `.rst`, `.txt`, `.adoc`, files in `docs/`, `doc/`, `documentation/`).

**If `--all` is given**: find all documentation files in the repo:
```bash
find . -type f \( -name "*.md" -o -name "*.rst" -o -name "*.adoc" -o -name "*.txt" \) \
  -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.venv/*"
```

**If a path or glob is given**: use it directly.

**If no documentation files are found**: stop and report "No documentation files found in scope."

### 2. Read All In-Scope Files

Read every in-scope file completely before producing any analysis output. Do not begin analysis until all files are read. Reading all files first is required to identify cross-file consistency findings (terminology drift, duplicate content, broken cross-references).

### 3. Classify the Document Type

For each file, identify its type before applying checks:

| Type | Indicators |
|---|---|
| **README** | Named `README*`, root-level, project overview |
| **Tutorial** | Step-by-step walkthrough, numbered instructions, "Getting Started" |
| **Reference** | API reference, configuration options, parameter tables |
| **Guide / How-to** | Explains how to accomplish a specific task |
| **Changelog / Release notes** | Version history, `CHANGELOG*`, `HISTORY*` |
| **Error message / UI copy** | Short strings, button labels, tooltips, alerts |
| **Inline code comment** | Appears inside source files |

Document type determines which checks apply (see Step 4). If a document matches more than one type, apply checks for all matching types. When the same check appears in multiple type sections with different severities, use the higher severity.

### 4. Apply the Review Checklist

For each file, run every applicable check. Mark each finding as **Must Fix**, **Should Fix**, or **Consider**.

#### Structure Checks (all types)

| Check | Severity |
|---|---|
| Link text is "click here", "here", "this link", or "this page" | Must Fix |
| Headings are absent in a document longer than ~400 words | Should Fix |
| Heading hierarchy is broken (e.g. H4 appears without H3) | Should Fix |
| Content is only partially covered — describes some but not all related items | Should Fix |
| Document exists but is unreachable from any other page or navigation | Should Fix |
| Heading uses title case instead of sentence case | Consider |

#### Content Quality Checks (all types)

| Check | Severity |
|---|---|
| Documentation describes behavior the code no longer has (verify against code if available) | Must Fix |
| Incorrect technical information (commands that don't work, wrong syntax) | Must Fix |
| No code example in a tutorial or guide | Must Fix |
| FAQ section present | Should Fix |
| Term or product name spelled or capitalized inconsistently across the document | Should Fix |
| Active voice absent — passive voice used where active voice is clearer | Consider |
| Second person ("you") absent in user-facing instructional content | Consider |

#### README Checks (README files only)

| Check | Severity |
|---|---|
| No problem statement or project purpose | Must Fix |
| No working code example | Must Fix |
| No installation instructions | Must Fix |
| License missing or not linked | Should Fix |
| No link to contribution guidelines | Should Fix |
| No link to issue tracker or support channel | Consider |

#### Tutorial / Guide Checks

| Check | Severity |
|---|---|
| Prerequisites not stated before they are needed (violates Cumulative principle) | Must Fix |
| Advanced concepts appear before foundational ones | Should Fix |
| No expected output shown after a command | Should Fix |

#### API Documentation Checks

| Check | Severity |
|---|---|
| Data structure defined inline in multiple endpoints instead of once | Should Fix |
| No example request/response shown | Should Fix |
| Error responses not documented | Should Fix |
| No description of authentication requirements | Should Fix |

#### Changelog / Release Notes Checks

| Check | Severity |
|---|---|
| Entry describes the change but not why it was made | Should Fix |
| Entry describes the change but not its impact on the user | Should Fix |
| Entry does not link to the issue, PR, or detailed resource | Consider |

#### Error Message / UI Copy Checks

| Check | Severity |
|---|---|
| Error message blames the user (e.g. "You did X wrong") | Must Fix |
| Error message is vague ("Something went wrong", "Error", "Failed") | Must Fix |
| Error message gives no actionable next step | Must Fix |
| UI label or tooltip is absent on an interactive element | Should Fix |
| Tone differs from the product voice in surrounding documentation | Consider |

#### Accessibility Checks (all types)

| Check | Severity |
|---|---|
| Image has no alt text | Must Fix |
| Alt text describes appearance rather than the information conveyed | Should Fix |
| Alt text exceeds two sentences | Consider |

#### Bias and Inclusion Checks (all types)

| Check | Severity |
|---|---|
| Figurative idiom references animal violence (e.g. "kill two birds") | Should Fix |
| Idiom likely to confuse non-native English speakers | Should Fix |
| Example names or personas are homogeneous | Consider |

### 5. Compile the Report

Aggregate findings into this structure for each file:

```
## Review: <filename>

**Type**: <README | Tutorial | Reference | Guide | Changelog | UI Copy>

### Must Fix
- <issue> — <why it matters> (line N)

### Should Fix
- <issue> — <why it matters> (line N)

### Consider
- <suggestion> — <trade-off> (line N)
```

When a finding has no specific line number (e.g. a missing section, a document-level structural problem), write `(document-level)` in place of the line reference.

If a file has no issues: `✓ <filename> — no issues found`

**Cross-file findings** (terminology drift, duplicate content, broken cross-references) appear in a separate section:

```
## Cross-File Findings

### Must Fix / Should Fix / Consider
- <issue> — affects <file-a>, <file-b>
```

### 6. Summary

After all files, write a one-paragraph summary:
- Overall state: publication-ready / needs work / significant gaps
- Most critical issue if any
- Any systemic pattern across files (e.g. "all tutorials are missing expected output")

### 7. Auto-Fix (only when `-f` is passed)

**If `-f` was not passed: stop here.**

Apply every **Must Fix** and **Should Fix** finding where the fix can be made by editing the documentation file. Do not apply **Consider** items.

Fixes that can be automated:
- Replacing "click here" link text with the destination title
- Removing FAQ sections: delete the FAQ heading and move its Q&A pairs into the most structurally appropriate existing section. If no appropriate section exists, add a `[TODO: relocate from FAQ]` marker and leave the content in place
- Adding alt text placeholders (`[TODO: alt text]`) for images missing it
- Fixing heading hierarchy
- Correcting inconsistent terminology (apply the first-used spelling throughout)
- Fixing title case headings to sentence case

Fixes that cannot be automated (report as **Needs Manual Fix**):
- Outdated technical content — requires knowledge of the current code behavior
- Missing code examples — requires domain knowledge to write
- Missing problem statements or project purposes — requires author input
- UI copy that lacks an actionable next step — requires product knowledge

After applying fixes, report:

```
## Fixes Applied

- <filename>:<line> — <what was fixed>

Remaining (Needs Manual Fix):
- <filename>:<line> — <issue>
```

### 8. Continuous Loop (only when `-fc` is passed)

**If `-fc` was not passed: stop here.**

Re-run Steps 3–6 on the same scope after Step 7. If Must Fix or Should Fix findings remain, fix them and review again. Repeat until:
- Zero Must Fix and Should Fix findings → print `✓ Clean` and stop
- 5 iterations completed → stop and report remaining findings as **Needs Manual Fix**
- A fix in pass N introduces a new Must Fix or Should Fix finding that was not present in pass N-1 → stop immediately and report the new finding as **Needs Manual Fix**. Do not attempt to auto-fix a finding introduced by a prior auto-fix.

Print a pass header at each iteration: `--- Pass 2 ---`

After the loop exits, print a **Session Summary**:

```
## Session Summary

### Remaining Findings
- <filename>:<line> — <issue> [Must Fix | Should Fix | Needs Manual Fix]
(or "None — all findings resolved")

### Consider Items
- <filename>:<line> — <suggestion>
(or "None")
```

---

## Rules

- Read all files before reporting — cross-file consistency findings require the full picture
- Apply the document-type classification before checking — a changelog is not graded like a tutorial
- Report findings with file and line number when possible
- Do not flag ARID (repetition) as a finding — some documentation repetition is correct and intentional
- Without `-f`: describe what to change and why — do not modify files
- With `-f` or `-fc`: apply automatable Must Fix and Should Fix changes directly; mark the rest as Needs Manual Fix
- If a finding appears in multiple files, report it once as a systemic issue rather than per-file
