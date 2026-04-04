---
paths:
  - "**/*.go"
---

# Go Security

## Secrets & Credentials

- Never hardcode secrets, API keys, tokens, or passwords in source code
- Load sensitive values from environment variables or a config file excluded from version control
- Use `os.Getenv` or a config library (e.g., `viper`, `envconfig`) — never string literals for credentials
- Add credential files to `.gitignore`

## SQL Injection

- Always use parameterized queries — never string-format SQL with user input:

```go
// Bad
query := fmt.Sprintf("SELECT * FROM users WHERE email = '%s'", email)

// Good
row := db.QueryRowContext(ctx, "SELECT * FROM users WHERE email = $1", email)
```

- Use an ORM or query builder that parameterizes automatically
- Never use `fmt.Sprintf`, `+`, or string interpolation to build SQL

## Command Injection

- Never pass user input to `os/exec` via shell: `exec.Command("sh", "-c", userInput)` is forbidden
- Always use the argument list form:

```go
// Bad
exec.Command("sh", "-c", "grep " + userInput)

// Good
exec.Command("grep", "--", userInput, filename)
```

- Validate and allowlist inputs before passing to any subprocess

## Path Traversal

- Always clean and validate file paths before use:

```go
clean := filepath.Clean(filepath.Join(baseDir, userPath))
if !strings.HasPrefix(clean, baseDir+string(os.PathSeparator)) {
    return errors.New("path traversal detected")
}
```

- Never serve or open files at paths derived from user input without this check

## SSRF (Server-Side Request Forgery)

- Validate URLs before making outbound HTTP requests from user-supplied input
- Use an allowlist of permitted hosts/schemes where possible
- Disable redirect following when not needed: `http.Client{CheckRedirect: func(...) error { return http.ErrUseLastResponse }}`
- Never proxy raw user-supplied URLs to internal services

## Cryptography

- Use `crypto/rand` for all security-sensitive random values — never `math/rand`:

```go
// Bad
n := mathrand.Int63()

// Good
b := make([]byte, 32)
_, err := cryptorand.Read(b)
```

- Use standard library crypto packages (`crypto/aes`, `crypto/sha256`) — never roll your own
- Use `bcrypt` or `argon2` for password hashing — never plain SHA or MD5
- Use `hmac.Equal` for constant-time secret comparison to prevent timing attacks

## TLS

- Never set `InsecureSkipVerify: true` in production `tls.Config`
- Use `tls.Config` with a minimum version of `tls.VersionTLS12`
- Pin certificates or use system roots — don't disable certificate verification

## Input Validation

- Validate all input at system boundaries: HTTP handlers, gRPC handlers, CLI flags, file readers
- Reject unexpected or oversized input early — set `http.MaxBytesReader` on request bodies
- Parse and validate before trusting: don't pass raw strings from requests into domain logic
