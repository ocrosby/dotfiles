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
| `.py` | `ruff check --quiet <file> && ruff format --check --quiet <file>` then basedpyright (see below) |
| `.go` | `cd <module-root> && golangci-lint run ./... && go test -race ./...` |
| `.feature` | `gherkin-lint <file>` (if available) |

For Go: if `golangci-lint` is not installed, fall back to `go vet ./...` — but note that `go vet` is a strict subset of golangci-lint and will miss issues that CI catches. Recommend installing golangci-lint to close the gap.

**For Python files, also run basedpyright** after ruff. Resolve the nearest `pyproject.toml`
root first (basedpyright must run from the package root to pick up the right config):

```bash
PKG_ROOT=<dir-of-file>
while [ ! -f "$PKG_ROOT/pyproject.toml" ] && [ "$PKG_ROOT" != "/" ]; do
  PKG_ROOT=$(dirname "$PKG_ROOT")
done
cd "$PKG_ROOT" && uv run basedpyright <file>
```

basedpyright failures are **Must Fix** — treat them the same as ruff failures. Pay
particular attention to these diagnostics that ruff does not catch:

| Diagnostic | What it means | Canonical fix |
|---|---|---|
| `reportUnusedCallResult` | Non-`None` return value silently discarded | Assign to `_`: `_ = await client.xadd(...)` |
| `reportUntypedFunctionDecorator` | Decorator from an untyped library | `# pyright: ignore[reportUntypedFunctionDecorator]` on the decorator line |
| `reportUnknownVariableType` | Import from a library without `py.typed` stubs | Import from the concrete submodule; add `# pyright: ignore[reportUnknownVariableType]` on the import line if unavoidable |
| `"X is not exported from module Y"` | Package re-exports not recognised (no `py.typed`) | Change `from pkg import X` → `from pkg.submodule import X` |
| Missing annotation on `ctx` in invoke tasks | `ctx` parameter has no type | Annotate as `ctx: Context` from `invoke.context` |
| `str \| bytes` assigned to `str` field | gRPC/low-level APIs return `str \| bytes` | Narrow with `v.decode() if isinstance(v, bytes) else v`; never use `str(v)` on bytes |

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

## Rules

- Report issues with file and line number when possible
- Distinguish between blocking issues and suggestions — not everything is a Must Fix
- Do not rewrite code unless the user asks; describe what to change and why
- If a pattern appears in multiple files, call it out as a systemic issue rather than repeating the same comment
