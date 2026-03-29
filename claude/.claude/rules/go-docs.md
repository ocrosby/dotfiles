---
paths:
  - "**/*.go"
---

# Go Documentation

## Godoc Conventions

- Every exported type, function, method, and package has a doc comment
- Unexported symbols do not require comments unless the logic is non-obvious
- Comments start with the name of the thing being documented

### Format

```go
// UserService manages user lifecycle operations.
type UserService struct { ... }

// CreateUser creates a new user with the given name and email.
// It returns ErrDuplicateEmail if the email is already registered.
func (s *UserService) CreateUser(ctx context.Context, name, email string) (*User, error) {
```

### Rules

- First sentence is a complete sentence starting with the symbol name
- Use present tense, third person: "CreateUser creates..." not "Create a user"
- Document error conditions: which errors can be returned and when
- Document concurrency safety: "safe for concurrent use" or "not safe for concurrent use"
- Package comment goes in `doc.go` or the primary file of the package

## README

- Every project has a README with: purpose, quickstart, configuration, and development setup
- Quickstart shows `go build` / `go run` and how to start the application
- Configuration documents all environment variables and flags

## API Documentation

- HTTP APIs document request/response formats in handler comments
- Use OpenAPI/Swagger generation tools if the project warrants it
- Document all environment variables and config flags in `config.go`
