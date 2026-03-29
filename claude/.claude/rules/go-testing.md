---
paths:
  - "**/*_test.go"
  - "**/testdata/**"
---

# Go Testing

## Framework

- Use the stdlib `testing` package — no external test frameworks
- Use `testify/assert` and `testify/require` for assertions if the project already uses them
- Use `httptest` for HTTP handler testing

## Structure

- Test files live next to the code they test: `user.go` → `user_test.go`
- Use `_test` package suffix for black-box tests: `package user_test`
- Use the same package for white-box tests when testing unexported functions
- `testdata/` directories for test fixtures (automatically ignored by `go build`)

## Writing Tests

### Table-driven tests

```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    string
        wantErr bool
    }{
        {name: "valid email", input: "a@b.com", want: "a@b.com"},
        {name: "empty email", input: "", wantErr: true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CreateUser(tt.input)
            if tt.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got.Email != tt.want {
                t.Errorf("got %q, want %q", got.Email, tt.want)
            }
        })
    }
}
```

### Test helpers

```go
func newTestUser(t *testing.T) *User {
    t.Helper()
    return &User{ID: "test-id", Name: "Test User", Email: "test@example.com"}
}
```

- Always call `t.Helper()` in test helper functions
- Use `t.Cleanup()` for teardown instead of `defer` when the cleanup is test-scoped
- Use `t.TempDir()` for temporary directories

### Interface-based testing

```go
type fakeRepo struct {
    users map[string]*User
}

func (r *fakeRepo) FindByID(ctx context.Context, id string) (*User, error) {
    u, ok := r.users[id]
    if !ok {
        return nil, ErrNotFound
    }
    return u, nil
}
```

- Define fakes that implement port interfaces — prefer fakes over mocking libraries
- Fakes live in the test file or a shared `testutil` package

## HTTP Handler Testing

```go
func TestGetUser(t *testing.T) {
    handler := NewHandler(&fakeRepo{users: map[string]*User{"1": {ID: "1", Name: "Alice"}}})
    srv := httptest.NewServer(handler)
    defer srv.Close()

    resp, err := http.Get(srv.URL + "/users/1")
    if err != nil {
        t.Fatalf("request failed: %v", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        t.Errorf("got status %d, want %d", resp.StatusCode, http.StatusOK)
    }
}
```

## Running Tests

```bash
go test ./...                    # all tests
go test ./internal/domain/...    # specific package
go test -race ./...              # with race detector
go test -count=1 ./...           # no caching
go test -cover ./...             # with coverage
```

## Anti-Patterns

- External test frameworks (`gocheck`, `ginkgo`) when stdlib suffices
- Not using `t.Run` for subtests — makes failures hard to identify
- Not using `t.Helper()` — error locations point to the helper, not the caller
- Mocking libraries when a simple fake implements the interface
- Tests that depend on execution order or shared mutable state
- Ignoring the race detector (`-race`)
