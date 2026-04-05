---
description: Go workspace conventions for monorepos using go.work — CI patterns, version sync, and tooling compatibility.
paths:
  - "go.work"
  - "**/go.mod"
  - ".github/workflows/*.yml"
  - "Taskfile.yml"
  - "Makefile"
---

# Go Workspace Conventions

## What is a Go workspace?

A `go.work` file at the repository root means the repo is a Go workspace — a collection of independent Go modules managed together. Commands like `go test ./...` or `golangci-lint run ./...` issued from the root **will fail** because `./...` does not span module boundaries.

## Running commands across modules

Whenever you need to run a Go toolchain command across all modules, iterate over `go.mod` files:

```bash
find . -name "go.mod" -not -path "*/vendor/*" | while read modfile; do
  dir=$(dirname "$modfile")
  echo "=== $dir ==="
  (cd "$dir" && <command>) || exit 1
done
```

Apply this pattern to:
- `go test ./... -race -count=1`
- `golangci-lint run ./...`
- `go mod tidy`
- `go build ./...`

If the project has a `Taskfile.yml` or `Makefile`, prefer `task lint` / `task test` / `make lint` / `make test` — they already encode the correct per-module iteration.

## CI: matrix lint, loop tests

In GitHub Actions, the recommended pattern for workspace repos is:

- **Lint**: use a matrix job with one entry per module so failures are reported independently (set `fail-fast: false` to avoid cascade cancellations):

```yaml
lint:
  strategy:
    fail-fast: false
    matrix:
      module:
        - libs/errors
        - services/auth-server
        # ... one entry per module listed in go.work
  steps:
    - uses: golangci/golangci-lint-action@v9
      with:
        version: latest
        working-directory: ${{ matrix.module }}
```

- **Tests**: a single job with a `find` loop is fine — test output streams naturally and failures are reported with the module path.

## Keeping Go versions in sync

The Go version declared in `go.work` and all `go.mod` files must match. Drift causes build failures:

- `go.work` declares the minimum workspace Go version (`go 1.26`)
- Every `go.mod` in the workspace must declare the same or a compatible version
- Run `go work sync` after bumping any `go.mod` version
- When the Go stdlib gains a build constraint (e.g., `//go:build go1.26`) the go.mod must declare at least that version or the file is excluded at compile time, causing `undefined` errors

## golangci-lint version compatibility

golangci-lint is compiled with a specific Go version. If the project's `go.mod` declares a higher Go version than the one used to compile golangci-lint, the linter will fail with errors like:

```
file requires newer Go version go1.26 (application built with go1.24)
```

Rules:
- **golangci-lint v1.x** was built with Go ≤ 1.24 — incompatible with modules declaring `go 1.26`
- **golangci-lint v2.x** was built with Go 1.26 — required for `go 1.26` modules
- In GitHub Actions, use `golangci/golangci-lint-action@v9` (resolves to v2.x) when modules declare `go 1.26` or later
- `golangci-lint-action@v6` caps at v1.64.8 (Go 1.24) and will fail on `go 1.26` modules

## golangci-lint config version

golangci-lint v2 requires `version: "2"` at the top of `.golangci.yml`. The v1 format is rejected with:

```
can't load config: unsupported version of the configuration: ""
```

v2 config differences from v1:
- Top-level `version: "2"` is required
- Formatter config moves from `linters-settings` to a top-level `formatters` section
- Linter settings move to `linters.settings`
- Exclusion rules move to `linters.exclusions.rules`
- `gosimple` is merged into `staticcheck` — do not list it separately

## Dependency version triangulation

In workspace repos where multiple services share dependencies (e.g., `go-openapi/spec`, `swag`), version upgrades must be tested across all modules. A version that works for one service may break another:
- Pin to a known-compatible combination and test all modules before merging
- When a swag/spec/jsonreference upgrade breaks compilation, check if the issue is in the spec version, not just swag
