---
description: Guides structural refactoring of Go code — improving design, layering, and clarity without changing behavior.
triggers:
  - /go-refactor
paths:
  - "**/*.go"
---

# Go Refactor

Use this skill for structural improvements: extracting packages, improving interfaces, fixing layering violations, and reducing complexity. This is distinct from `/go-migrate` (which replaces deprecated patterns) — refactoring changes design, not API versions.

## Workflow

### 1. Understand Before Changing

Read the target file(s) and answer:
- What is this code responsible for?
- Why was it written this way? (Check git log for context: `git log --follow -p <file>`)
- What constraints or trade-offs drove the current design?

Do not refactor what you do not yet understand.

### 2. Identify the Problem

Classify the structural issue:

| Smell | Symptom |
|---|---|
| God struct/package | One type or package does too many unrelated things |
| Layering violation | Domain code imports HTTP/DB packages, or adapters contain business logic |
| Interface too wide | Interface has >5 methods; callers only use 2-3 of them |
| Concrete dependency | Code depends on a struct rather than an interface |
| Implicit coupling | Two packages share mutable state or call each other circularly |
| Duplicated logic | Same algorithm copied across 3+ places (Rule of Three) |
| Shallow abstraction | Wrapper adds no value — just passes through to one method |

### 3. Plan the Refactor

Before changing any code, state the plan:
- What specifically will change
- What will not change (behavior, public API, or both)
- What tests need to be written first to protect the refactor

Get confirmation before proceeding.

### 4. Write Tests First

If the code under refactor isn't covered by tests, write characterization tests before touching anything:

```go
func TestUserService_CreateUser_existingBehavior(t *testing.T) {
    // captures current behavior — not ideal behavior, current behavior
}
```

These tests protect against regressions during restructuring.

### 5. Refactor in Small Steps

Apply one change at a time, running `go test ./...` after each step:

#### Extract a package
- Move related types and functions into a new package
- Update import paths
- Verify the old package no longer has circular imports

#### Narrow an interface
```go
// Before: wide interface
type Store interface {
    CreateUser(...) error
    GetUser(...) (*User, error)
    UpdateUser(...) error
    DeleteUser(...) error
    ListUsers(...) ([]*User, error)
    CreateSession(...) error   // <-- unrelated
    DeleteSession(...) error   // <-- unrelated
}

// After: split by consumer
type UserStore interface {
    CreateUser(...) error
    GetUser(...) (*User, error)
    UpdateUser(...) error
    DeleteUser(...) error
    ListUsers(...) ([]*User, error)
}

type SessionStore interface {
    CreateSession(...) error
    DeleteSession(...) error
}
```

#### Fix a layering violation
- Move business logic from the adapter into the domain service
- Replace concrete type references with interface references
- Inject the dependency via the constructor

#### Extract duplicated logic
- Apply Rule of Three — extract only when the same pattern appears 3+ times
- Extract to the package that owns the concept, not to a generic `utils` package

### 6. Verify

```bash
go test ./... -race         # no regressions, no races
go vet ./...                # no vet warnings
golangci-lint run           # no lint issues
```

Confirm the public API (exported symbols and their signatures) is unchanged, or explicitly note what changed and why.

## Review Checklist

- [ ] No behavior changes — only structural improvements
- [ ] Tests written before refactoring to protect behavior
- [ ] All tests pass after refactoring
- [ ] Layer boundaries respected: domain has no external imports
- [ ] No new global state introduced
- [ ] Interfaces defined at the consumer side, not the implementer
