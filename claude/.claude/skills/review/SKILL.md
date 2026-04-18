---
description: Runs a structured code review of changed files by delegating to language-specialist reviewer agents.
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
/review -f                  # review + automatically fix all Must Fix and Should Fix findings
/review -f <file-or-glob>   # same, scoped to specific files
/review -fc                 # review + fix + repeat until no findings remain
/review -fc <file-or-glob>  # same, scoped to specific files
```

- `-f` — fix all findings once, then stop
- `-fc` — fix all findings, re-review, fix again, repeat until the review is clean (implies `-f`)
- Without either flag, the skill only reports

## Workflow

### 1. Identify the Scope

If no argument is given, run `git diff --name-only HEAD` to find changed files.
If an argument is given, use it as the file list or pass it to `git diff --name-only <ref>`.

Group files by language.

### 2. Run Linters

Before delegating to reviewer agents, run the appropriate linter on each changed file. Lint failures are **Must Fix** — do not proceed to the semantic review without reporting them.

For Go files, always resolve the module root first — do not run from the changed file's directory, as that only lints one package and misses the rest of the module:

```bash
# Find the module root (directory containing go.mod)
MODULE_ROOT=$(cd $(dirname <file>) && go env GOMODCACHE 2>/dev/null; cd $(dirname <file>) && git rev-parse --show-toplevel)
# More reliably:
MODULE_ROOT=$(dirname <file>); while [ ! -f "$MODULE_ROOT/go.mod" ] && [ "$MODULE_ROOT" != "/" ]; do MODULE_ROOT=$(dirname $MODULE_ROOT); done
```

| Extension | Linter command (run from module/project root) |
|---|---|
| `.lua` | `stylua --check <file>` (if available); `luacheck --quiet <file>` (if available) |
| `.py` | `ruff check --quiet <file> && ruff format --check --quiet <file>` |
| `.go` | `cd <module-root> && golangci-lint run ./... && go test -race ./...` |
| `.feature` | `gherkin-lint <file>` (if available) |

For Go: if `golangci-lint` is not installed, fall back to `go vet ./...` — but note that `go vet` is a strict subset of golangci-lint and will miss issues that CI catches. Recommend installing golangci-lint to close the gap.


Report any lint errors under a **Lint** section before the per-file review. Example:

```
## Lint Failures (Must Fix before merge)
- internal/adapters/cli/verify.go — golangci-lint: error return value not checked (errcheck)
```

Do not proceed to the semantic review until lint failures are resolved.

### 3. Detect the Language and REST API Presence

| Extension / Path | Reviewer Agent |
|---|---|
| `.go` | `go-reviewer` |
| `.py` | `py-reviewer` |
| `.lua` | `nvim-reviewer` |
| `.feature` | `gherkin-reviewer` |
| `skills/*/SKILL.md` | `skill-reviewer` |
| Other | Review inline: general quality, security (OWASP Top 10), readability |

**Additionally**, detect whether any changed files define HTTP endpoints. A file defines HTTP endpoints if it matches any of these patterns:

- Contains route registrations: `router.GET`, `router.POST`, `app.get(`, `@app.route`, `http.HandleFunc`, `mux.Handle`, `router.Handle`, `APIRouter()`, `@router.get`, `@router.post`, `r.GET`, `r.POST`, `r.PUT`, `r.PATCH`, `r.DELETE`
- Lives under a path matching `**/routes/**`, `**/handlers/**`, `**/controllers/**`, `**/views/**`, `**/api/**`

If REST API patterns are detected, invoke `rest-reviewer` on those files **in addition to** the language-specific agent.

### 4. Delegate to Reviewer Agents

For each language group, invoke the appropriate reviewer agent. Pass it the specific files to review.

The agents check against their full language-specific criteria (conventions, architecture, error handling, idioms, testing) and return structured findings organized by severity.

If `rest-reviewer` was triggered, run it against the files containing HTTP endpoint definitions. Merge its findings into the per-file report under a `### REST API` subsection.

For non-code files (config, YAML, Markdown), review inline:
- **Security**: injection risks, hardcoded credentials, sensitive data exposure
- **Quality**: naming clarity, dead content, structural issues

For `action.yml` / `action.yaml` files (GitHub Action definitions), apply this checklist:

| Check | Rule |
|---|---|
| `name` uniqueness | Must be globally unique across the marketplace; should be suffixed with `by Jedi Knights` (e.g. `Semantic Release by Jedi Knights`) |
| `description` length | Must be **< 125 characters** — GitHub truncates longer descriptions on the marketplace |
| `branding` present | `branding.icon` and `branding.color` should be set |
| `inputs` documented | Every input must have a `description`; sensitive inputs must set `required: false` and document the env var fallback |
| `runs.using` | Composite (`using: composite`) steps must all set `shell:`; `node20` is preferred over `node16` for JS actions |
| Secrets in composite | Never pass `secrets.*` directly as `env:` values inside composite `run:` steps — pass via `inputs` only |

For `.github/workflows/*.yml` files, apply this additional checklist:

| Check | What to look for |
|---|---|
| Go workspace | If `go.work` exists, `go test ./...` and `golangci-lint run ./...` from root will fail — commands must iterate per-module |
| golangci-lint version | `golangci-lint-action@v9` for Go 1.26+ modules; v6 caps at golangci-lint v1 (built with Go 1.24) |
| golangci-lint config | v2 format requires `version: "2"` in `.golangci.yml`; v1 config silently rejected |
| Go version sync | All `go.mod` files and `go.work` must declare the same Go version |
| Matrix fail-fast | Default `fail-fast: true` on matrix jobs cascades cancellations; set `fail-fast: false` for independent module jobs |
| Permissions | Minimum required: `contents: read` for checkout; release workflows need `contents: write` + `pull-requests: write` + `issues: write` |
| Concurrency | Release workflows should have `concurrency: { group: release, cancel-in-progress: false }` to prevent parallel releases |
| Action versions | Prefer pinned major versions (`@v4`, `@v9`) over `@latest` to avoid unexpected breakage |

### 5. Compile the Report

Aggregate agent findings into this structure for each file:

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

### 6. Summary

After all files are reviewed, write a one-paragraph summary:
- Overall assessment: ready to ship / needs work / significant concerns
- The most important issue if any
- Any cross-cutting pattern across files worth noting

### 7. Auto-Fix (only when `-f` is passed)

**If `-f` was not passed: stop here.**

If `-f` was passed, address every **Must Fix** and **Should Fix** finding from the report. Do not apply **Consider** items — those remain suggestions.

Work through findings in this order:
1. All Must Fix items across all files
2. All Should Fix items across all files

For each fix:
- Apply the change directly using Edit or Write
- Do not ask for confirmation — the `-f` flag is the authorization

After all fixes are applied, re-run the linters from Step 2 on the modified files. Report a final **Fixes Applied** section:

```
## Fixes Applied

- <filename>:<line> — <what was fixed>
- <filename>:<line> — <what was fixed>

Linters: ✓ clean  (or list any remaining failures)
```

If a finding cannot be automatically fixed (e.g. requires architectural change, missing context, or external dependency), note it as **Needs Manual Fix** instead of skipping it silently.

### 8. Continuous Loop (only when `-fc` is passed)

**If `-fc` was not passed: stop here.**

After Step 7 completes, run a full second review (Steps 1–6) on the same scope. If the second review produces any Must Fix or Should Fix findings, apply them (Step 7) and review again. Repeat until either:

- The review reports zero Must Fix and Should Fix findings → print `✓ Clean — no further findings` and stop
- 5 iterations have been completed without reaching clean → stop and report remaining findings as **Needs Manual Fix**, noting the iteration cap was reached

Track the iteration count and print a header at the start of each pass:

```
--- Pass 2 ---
--- Pass 3 ---
```

Consider items are never a reason to continue looping — only Must Fix and Should Fix count.

Once the loop exits (clean or iteration cap reached), print a final **Session Summary** covering all passes:

```
## Session Summary

### Remaining Findings
- <filename>:<line> — <issue> [Must Fix | Should Fix | Needs Manual Fix]
(or "None — all findings resolved" if clean)

### Consider Items
- <filename>:<line> — <suggestion>
(or "None" if there were no Consider items across any pass)
```

Collect Consider items from every pass (not just the last), de-duplicate them, and include them all. This gives a complete picture of optional improvements regardless of how many iterations ran.

## Rules

- Report issues with file and line number when possible
- Distinguish between blocking issues and suggestions — not everything is a Must Fix
- Without `-f`: describe what to change and why — do not modify code
- With `-f` or `-fc`: apply all Must Fix and Should Fix changes directly without asking
- `-fc` loops until clean or 5 iterations — whichever comes first
- If a pattern appears in multiple files, call it out as a systemic issue rather than repeating the same comment
