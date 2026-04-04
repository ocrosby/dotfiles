---
description: Generates and audits Go package documentation following godoc conventions.
triggers:
  - /go-docs
paths:
  - "**/*.go"
---

# Go Documentation Writer

## Workflow

### 1. Scan for Missing Documentation

Find all exported symbols without doc comments:

```bash
# Find exported funcs/types/vars without preceding comments
grep -n "^func [A-Z]\|^type [A-Z]\|^var [A-Z]\|^const [A-Z]" **/*.go
```

Cross-reference against symbols that already have a comment on the preceding line. Report which exported symbols are undocumented.

### 2. Write Package Documentation

If the package lacks a package-level comment, add it to `doc.go` (create if it doesn't exist) or the primary file:

```go
// Package users manages user lifecycle operations including creation,
// authentication, and profile management.
//
// The primary entry point is [UserService], which requires a [Repository]
// implementation to be injected at construction time.
package users
```

### 3. Document Exported Symbols

For each undocumented exported symbol, write a doc comment following godoc conventions:

```go
// UserService manages user lifecycle operations.
// It is safe for concurrent use.
type UserService struct { ... }

// CreateUser creates a new user with the given name and email.
// It returns [ErrDuplicateEmail] if the email is already registered.
// The ctx parameter is used for cancellation and deadline propagation.
func (s *UserService) CreateUser(ctx context.Context, name, email string) (*User, error)

// ErrDuplicateEmail is returned by CreateUser when the given email
// is already associated with an existing account.
var ErrDuplicateEmail = errors.New("duplicate email")
```

### 4. Format Rules

- First sentence starts with the symbol name, present tense, third person
  - `CreateUser creates...` not `Create a user` or `This function creates`
- Document all error return conditions with their sentinel error references
- State concurrency safety explicitly when relevant: "safe for concurrent use" or "not safe for concurrent use"
- Use `[SymbolName]` cross-reference syntax (Go 1.19+) to link to related types
- Do not document unexported symbols unless the logic is genuinely non-obvious

### 5. Verify

```bash
go doc ./...        # Verify all exported symbols render correctly
godoc -http=:6060   # Browse rendered docs at localhost:6060
```

## Review Checklist

- [ ] Every exported type has a doc comment starting with its name
- [ ] Every exported function/method documents its error returns
- [ ] Package-level comment exists in `doc.go` or the primary file
- [ ] Concurrency safety is stated on types that are shared across goroutines
- [ ] `[SymbolName]` cross-references used instead of bare names where helpful
- [ ] No empty or placeholder comments (`// TODO: document this`)
