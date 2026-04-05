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
```

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

### 4. Detect the Language

| Extension / Path | Reviewer Agent |
|---|---|
| `.go` | `go-reviewer` |
| `.py` | `py-reviewer` |
| `.lua` | `nvim-reviewer` |
| `.feature` | `gherkin-reviewer` |
| `skills/*/SKILL.md` | `skill-reviewer` |
| Other | Review inline: general quality, security (OWASP Top 10), readability |

### 5. Delegate to Reviewer Agents

For each language group, invoke the appropriate reviewer agent. Pass it the specific files to review.

The agents check against their full language-specific criteria (conventions, architecture, error handling, idioms, testing) and return structured findings organized by severity.

For non-code files (config, YAML, Markdown), review inline:
- **Security**: injection risks, hardcoded credentials, sensitive data exposure
- **Quality**: naming clarity, dead content, structural issues

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

### 6. Compile the Report

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

### 7. Summary

After all files are reviewed, write a one-paragraph summary:
- Overall assessment: ready to ship / needs work / significant concerns
- The most important issue if any
- Any cross-cutting pattern across files worth noting

## Rules

- Report issues with file and line number when possible
- Distinguish between blocking issues and suggestions — not everything is a Must Fix
- Do not rewrite code unless the user asks; describe what to change and why
- If a pattern appears in multiple files, call it out as a systemic issue rather than repeating the same comment
