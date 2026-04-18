---
paths:
  - "**/*.go"
---

# Go Documentation

## Godoc Conventions

- Every type, function, method, and package — exported or unexported — has a doc comment
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
- Package comment goes in `doc.go` for multi-file packages; single-file packages can comment the `package` declaration directly
- Use named return parameters when they clarify which value is which (e.g., `(value, nextPos int)`)
- Line comments (`//`) are the norm; block comments (`/* */`) for package-level or disabling code
- Single space between sentences in comments — not double space
- Compiler directives (`//go:generate`, `//go:build`) use no space after `//` — this distinguishes them from human-readable comments; separate them from the package comment with a blank line
- For variables and constants, comment what they contain, not where they are used:

```go
// DefaultTimeout is the maximum duration to wait for a response
// before aborting the request. Configurable per-client.
var DefaultTimeout = 30 * time.Second
```

### Example Functions

- Write `Example*` functions to document and test public API behavior:

```go
func ExampleEncode() {
    var buf bytes.Buffer
    err := json.NewEncoder(&buf).Encode(map[string]int{"a": 1})
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(buf.String())
    // Output: {"a":1}
}
```

- `// Output:` comments are verified by `go test` — they serve as both documentation and regression tests
- Example functions appear in godoc alongside the symbols they document

## README

- Every project has a README with: purpose, quickstart, configuration, and development setup
- Quickstart shows `go build` / `go run` and how to start the application
- Configuration documents all environment variables and flags

## API Documentation

- HTTP APIs document request/response formats in handler comments
- Use OpenAPI/Swagger generation tools if the project warrants it
- Document all environment variables and config flags in `config.go`
