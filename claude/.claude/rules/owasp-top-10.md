---
description: OWASP Top 10 recognition signals and mandatory behaviors. Apply to all code that handles untrusted input, authentication, authorization, secrets, persistence, network I/O, or deployment configuration.
---

# OWASP Top 10 Application Security

Sources: https://owasp.org/Top10/2025/ and https://owasp.org/Top10/2021/. Categories below follow the 2025 list; both 2025 and 2021 IDs are noted for searchability. The 2025 list may still receive editorial updates — verify the official page if a category name appears to differ.

The OWASP Top 10 is a **recognition list**, not an implementation guide. This rule names the risks and the code-level signals that should trigger you to apply mitigations. For language-specific tactics see the Go, Python, and Neovim/Lua security rules in this same `rules/` directory (`go-security.md`, `py-security.md`, `nvim-security.md`).

When generating or reviewing code, scan it against the signal tables below before declaring it complete. If a signal fires, apply the mandatory behavior for that category.

---

## A01:2025 — Broken Access Control

Failure to enforce restrictions on what an authenticated user can do. The most prevalent OWASP risk in both 2021 and 2025.

### Signals

| Signal | Mitigation |
|---|---|
| Endpoint reads `id` from the URL and queries the resource without an ownership check | Add `WHERE owner_id = ?` (or equivalent policy check) to every lookup |
| Authorization decided by a field in the request (role in JWT claim accepted as-is, role in form body, hidden field) | Resolve identity and role from server state, not the request body |
| `if user.is_admin` checked in some handlers but not others on the same resource | Move authorization into one shared middleware/decorator/policy module |
| New endpoint added without an explicit auth/role check | Make the framework default-deny; an unannotated endpoint should refuse to register |
| `next` / `redirect_to` / `returnUrl` parameter dereferenced without validation | Validate target against an allowlist of internal paths or hosts before redirecting |
| File path from user input passed to `open` / `read` without confinement | Resolve to absolute path and verify it lives under an expected base directory |
| URL from user input passed to `fetch` / `http.Get` / `requests.get` | Validate scheme + host against an allowlist; block private and metadata IPs (SSRF — see also A06) |

### Mandatory behaviors

- **Default deny.** Every protected route must require an explicit allow decision. Never write a handler whose security depends on the framework "probably" enforcing auth at a layer above.
- **Verify ownership on every resource lookup.** `WHERE id = ?` is not enough — it must be `WHERE id = ? AND owner_id = ?` (or equivalent policy check).
- **Trust the server's view of identity, never the client's.** A role or tenant ID coming from the request body is input, not authority.
- **Enforce authorization in one place per resource** (a policy module, middleware, or decorator) so a new handler can't accidentally skip the check.
- **Validate redirect targets** against an allowlist of internal paths or hosts. Never redirect to an arbitrary user-supplied URL.
- **Validate outbound URLs** before fetching from user-supplied input (SSRF). Reject `file://`, `gopher://`, `127.0.0.0/8`, link-local, and metadata IPs (`169.254.169.254`).

---

## A02:2025 — Security Misconfiguration

Insecure defaults, partial hardening, or environment leakage. Promoted from A05:2021 to A02:2025 — it is now the second-most-prevalent risk.

### Signals

| Signal | Mitigation |
|---|---|
| Stack trace, ORM error, or framework debug page returned to the client on error | Map all exceptions to a generic message; log detail server-side only |
| `DEBUG = True`, `app.debug = True`, `NODE_ENV != "production"` reachable in deploy paths | Drive debug from an env var that defaults off; assert it is off at startup in prod |
| Default credentials in seed data, fixtures, or compose files committed to repo | Replace with placeholder values; load real credentials from env/secret manager |
| Missing security headers (`Strict-Transport-Security`, `Content-Security-Policy`, `X-Content-Type-Options`, `Referrer-Policy`) | Add a middleware that sets them on every response by default |
| CORS configured as `Access-Control-Allow-Origin: *` with credentials | Allowlist specific origins; never combine `*` with credentialed requests |
| Admin or metrics endpoint exposed on the same listener as public traffic without auth | Bind to a separate listener/network or require auth + IP allowlist |
| Cookie missing `HttpOnly`, `Secure`, or `SameSite` | Set all three by default; opt out per-cookie only with a justifying comment |

### Mandatory behaviors

- **Fail closed on configuration absence.** Missing `DATABASE_URL` or `SECRET_KEY` should crash on startup, not fall back to a default.
- **Strip internal error detail from client responses.** Log the trace server-side; return a stable error code/message to the caller.
- **Set security headers by default** in middleware applied to all responses; opt out per-route only with comment explaining why.
- **Set cookies as `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict`)** unless there is a documented reason not to.
- **Never check in real credentials.** Use `.env.example` with placeholders; ensure `.env` is in `.gitignore`.

---

## A03:2025 — Software Supply Chain Failures

Renamed and broadened from A06:2021 ("Vulnerable and Outdated Components") to cover the entire build/deploy pipeline.

### Signals

| Signal | Mitigation |
|---|---|
| Dependency added without a lockfile entry (`go.sum`, `uv.lock`, `package-lock.json`) | Regenerate the lockfile and commit it in the same change |
| `curl ... \| sh` or `wget ... \| bash` in install scripts, Dockerfiles, or CI | Pin a checksum and verify it before executing, or replace with a packaged install |
| Docker base image referenced by floating tag (`:latest`, `:slim`) instead of a pinned digest | Pin to `image@sha256:...` and update via a bot/PR |
| CI workflow uses third-party action by tag instead of commit SHA | Replace `@v1` with `@<full-commit-sha>` |
| New dependency from an unfamiliar registry/namespace, or a typo-similar name to a popular package | Verify maintainer history, download counts, and exact name before adding |
| Generated code or vendored binary committed without provenance | Document the source command/version in a sibling file or commit message |

### Mandatory behaviors

- **Pin everything.** Application dependencies via lockfile, CI actions by commit SHA, container images by digest where the platform supports it.
- **Run a vulnerability scanner in CI** (`uv audit` / `pip-audit`, `govulncheck`, `npm audit`, GitHub Dependabot, etc.) and treat findings as build failures unless explicitly waived.
- **Verify before executing.** Prefer signed releases and checksum verification over `curl | sh`. If a remote install is unavoidable, pin the script's checksum.
- **Be skeptical of new dependencies.** Before adding one, check: maintainer history, download counts, whether the std lib already covers it, and whether the name resembles a more popular package.

---

## A04:2025 — Cryptographic Failures

Sensitive data exposure caused by weak, missing, or misused cryptography. (A02:2021.)

### Signals

| Signal | Mitigation |
|---|---|
| `md5`, `sha1`, or unsalted `sha256` used for passwords | Use `bcrypt`, `argon2id`, or `scrypt` with a tuned work factor |
| `Math.random()`, `random.random()`, `math/rand` used for tokens, session IDs, or password resets | Use the OS CSPRNG (`crypto/rand`, `secrets`, `crypto.randomBytes`) |
| Symmetric key, JWT signing secret, or DB password in source code, fixtures, or commit history | Move to env/secret manager; rotate any value that was committed |
| `InsecureSkipVerify: true`, `verify=False`, `rejectUnauthorized: false` in TLS clients | Re-enable verification; fix the cert chain instead of bypassing it |
| HTTP (not HTTPS) used for any endpoint that carries credentials, tokens, or PII | Force HTTPS at the listener and via HSTS |
| `==` used to compare a secret, signature, or HMAC | Use the language's constant-time comparison helper (see language security rule) |
| Encryption mode is ECB, or CBC without authentication; nonce is constant or reused | Switch to AEAD (AES-GCM, ChaCha20-Poly1305) with a fresh random nonce per message |

### Mandatory behaviors

- **Passwords:** `bcrypt`, `argon2id`, or `scrypt` — never a raw hash. Tune work factor for the deployment.
- **Random tokens:** use the OS CSPRNG (`crypto/rand`, `secrets.token_urlsafe`, `crypto.randomBytes`). Never `math/rand` or `Math.random` for anything security-relevant.
- **Symmetric encryption:** use AEAD (AES-GCM, ChaCha20-Poly1305) from a vetted standard library. Never roll your own; never reuse a nonce.
- **Secret comparison:** use the language's constant-time comparison helper (see the language security rule for the specific function name).
- **Transport:** TLS 1.2+ with certificate validation enabled. Never disable verification outside of explicit local test fixtures.

---

## A05:2025 — Injection

Untrusted input parsed as code or commands. (A03:2021. XSS lives here.)

### Signals

| Signal | Mitigation |
|---|---|
| String interpolation or `+` building a SQL, NoSQL, or LDAP query | Replace with parameterized queries / ORM placeholders |
| `subprocess.run(..., shell=True)`, `exec.Command("sh", "-c", ...)`, `os.system(...)` with any dynamic value | Use the argument-list form with no shell; allowlist or validate the binary |
| `eval`, `exec`, `Function(...)`, `loadstring`, `vim.api.nvim_exec` on data sourced from input | Replace with a fixed dispatch table or a strict allowlist of permitted values |
| Deserialization of untrusted input via `pickle.loads`, `yaml.load`, `unserialize` | See A08 — switch to JSON or a schema-validated format |
| HTML built by string concatenation; template engine called without autoescape | Use a template engine with autoescape on by default |
| `dangerouslySetInnerHTML`, `v-html`, `.innerHTML = userInput` | Render via the framework's text node API; sanitize HTML only when truly needed |
| User input passed to `Path(...)` / `open(...)` without confinement | Resolve to absolute path, then verify it lives under an expected base directory |

### Mandatory behaviors

- **SQL/NoSQL:** parameterized queries or an ORM that parameterizes. No string-built queries — ever.
- **Subprocess:** argument-list form, no shell. Validate or allowlist the binary; quote-escape is not a substitute.
- **Templates:** use a template engine with autoescape on by default. Treat opting out as a security review point.
- **Deserialization:** see A08 — never `pickle`, `marshal`, Java serialization, or `unserialize` on untrusted input.
- **Paths:** resolve to an absolute path, then verify the result is inside an expected base directory. Reject otherwise.

---

## A06:2025 — Insecure Design

Vulnerabilities baked in by missing security thinking at design time, not by a single buggy line.

### Signals

| Signal | Mitigation |
|---|---|
| New auth, password-reset, or signup flow without rate limiting or lockout | Add per-account and per-IP rate limits with progressive backoff |
| File upload accepted without size, type, or content-scan limits | Cap size; validate declared + sniffed content type; store outside the web root |
| Workflow that depends on a client-side check for correctness | Re-validate every business rule on the server |
| Single boolean check decides a sensitive action with no audit trail | Add a second factor (email confirm, MFA, peer review) and log the action |
| Multi-step state machine relies only on the client's posted "current step" value | Track step state server-side; reject jumps that don't match the recorded state |
| Webhook or callback endpoint accepts payloads without signature verification | Verify signature with constant-time compare against a server-held secret |
| Outbound URL fetched from user-supplied input without scheme/host filtering | Allowlist scheme + host; block private, link-local, and metadata IPs (SSRF) |

### Mandatory behaviors

- **Rate-limit anything that maps an input to a real-world cost** (login, password reset, signup, OTP send, expensive search).
- **Constrain file uploads** by size, declared type, and sniffed content type. Store outside the web root. Never serve back at a path the user controls.
- **Re-validate every business rule on the server.** Client-side validation is UX, not security.
- **Verify webhook signatures** with a constant-time comparison against a server-held secret.
- **Design for least authority.** A subsystem that only needs read should not get write; a service that only needs one bucket should not get the whole account.

---

## A07:2025 — Authentication Failures

Compromised identity verification or session management. (A07:2021.)

### Signals

| Signal | Mitigation |
|---|---|
| Password policy is "minimum 6 characters" or accepts the username as the password | Enforce a length floor (12+) and check against a breached-password list |
| Session ID generated by an app-level RNG or sequential counter | Generate session IDs with the OS CSPRNG via the framework's session helper |
| Session does not rotate after login or privilege change | Issue a new session ID on login, logout, and role change |
| `jwt.decode(..., verify=False)` or signature verification skipped on any path | Always verify; remove the option from production code paths |
| Logout marks the session inactive in the DB but does not invalidate the JWT | Use short-lived tokens + a server-checked revocation list, or use stateful sessions |
| MFA endpoint can be skipped by directly requesting the post-MFA URL | Gate post-MFA routes on server-side state proving MFA was completed |
| Password reset token is short, sequential, or non-expiring | Use a CSPRNG token of 128+ bits, single-use, expiring within minutes |

### Mandatory behaviors

- **Use established auth libraries.** Do not implement password hashing, session signing, or JWT verification by hand.
- **Always verify token signatures.** `verify=False` is forbidden in production paths; if used in tests, gate behind a test-only flag.
- **Rotate session identifiers** on login, logout, and privilege change.
- **Reset / verification tokens** must be CSPRNG-generated, single-use, and time-bounded (minutes, not days).
- **Enforce auth-step ordering server-side.** Reaching step N without state proving step N-1 must fail.

---

## A08:2025 — Software or Data Integrity Failures

Trusting code, updates, or data without verifying integrity. (A08:2021.)

### Signals

| Signal | Mitigation |
|---|---|
| Auto-update fetches a binary or script over HTTP, or HTTPS without signature check | Verify a detached signature against a pinned public key before applying |
| `pickle.loads`, `yaml.load` (without `SafeLoader`), Java `ObjectInputStream`, PHP `unserialize` on untrusted input | Switch to JSON, protobuf, or `yaml.safe_load`; reserve binary serialization for trusted in-process use |
| CI publishes artifacts without signing them | Sign on publish; verify signature in deploy/install step |
| Application accepts and acts on a JWT / cookie / payload without signature validation | Validate signature before reading any field; reject otherwise |
| Data flows from "untrusted" to "trusted" zones with no validation step | Add a schema validation at the boundary; treat upstream as untrusted regardless of source |

### Mandatory behaviors

- **Treat every input crossing a trust boundary as untrusted** until validated against a schema. "It came from our own service" is not validation.
- **Use safe deserialization formats** (JSON, protobuf with schemas, `yaml.safe_load`). Reserve binary serialization for trusted, in-process channels.
- **Sign release artifacts and verify signatures on install.**
- **Never auto-execute remotely-fetched code** without integrity verification.

---

## A09:2025 — Security Logging and Alerting Failures

Insufficient observability to detect, investigate, or respond to incidents. (A09:2021, slightly renamed.)

### Signals

| Signal | Mitigation |
|---|---|
| Auth failures, authorization denials, and privilege changes are not logged | Emit a structured event with who, what, when, source IP, request ID, outcome |
| Logs include passwords, tokens, PII, full request bodies | Redact at the log layer; use a `SecretStr`-style type that refuses to serialize |
| All log lines are at the same level, no structured fields | Use leveled, structured (key/value or JSON) logging so events are queryable |
| No correlation ID / request ID propagated across services | Generate at edge, forward in headers, include in every log line and error response |
| Errors are caught and swallowed silently | Log at a level monitoring will see, even if the error is recoverable |

### Mandatory behaviors

- **Log security-relevant events** with enough context to investigate: who, what, when, source IP, request ID, outcome.
- **Never log secrets or PII.** Redact before emit. Use a `SecretStr`-style type that refuses to serialize.
- **Use structured logging** (key/value or JSON) so events can be queried and alerted on.
- **Propagate a correlation ID** through every service hop and include it in error responses so users and operators reference the same identifier.
- **Don't swallow exceptions silently.** At minimum log them at a level that monitoring will see.

---

## A10:2025 — Mishandling of Exceptional Conditions

New in 2025. Errors, timeouts, and unexpected states that leave the system in an unsafe or information-leaking state.

### Signals

| Signal | Mitigation |
|---|---|
| `try / except: pass` or `_ = err` discarding errors from a security-relevant call | Propagate or log the error and fail closed |
| Auth check inside a `try`; failure path falls through as "allowed" | Restructure so any error or exception denies, never permits |
| Error response includes stack trace, SQL fragment, internal hostname, or library version | Map to a generic message for the client; keep the detail in server logs |
| Resource (file handle, lock, transaction, mutex) not released on the error path | Use `defer` / `with` / `try-finally` / `using` to release on every path |
| Retry loop with no backoff or cap; no circuit breaker on a flaky dependency | Add exponential backoff, a cap, and a circuit breaker around the dependency |
| Default branch of a `switch`/`match` on a security-critical enum is unhandled or "permit" | Make the default branch deny and surface an explicit error |

### Mandatory behaviors

- **Fail closed on security decisions.** If the auth/policy/crypto call errors, deny — never allow.
- **Never leak internals in error responses.** Map exceptions to a stable user-facing error; log the detail server-side.
- **Use language facilities for cleanup** (`defer`, `with`, `try/finally`, `using`) to release resources on every path.
- **Handle every case in security-critical dispatch.** No silent default — exhaustive match or explicit deny.
- **Bound retries** with exponential backoff and a cap. Add a circuit breaker for any external dependency whose failure could cascade.

---

## Mandatory Behaviors (cross-cutting)

**When generating code:** before declaring a change complete, scan the diff against the signal tables above. If a signal fires, apply the matching mandatory behavior. For any change that touches a trust boundary (auth, input parsing, persistence, network I/O, deserialization, error paths), always state which OWASP categories you considered — e.g. `A01, A05, A09 considered — none triggered`.

**When reviewing code:** report findings using the three-severity format from `rules/docs-principles.md`:
- **Must Fix** — an OWASP signal fires and the corresponding mitigation is missing
- **Should Fix** — a signal fires and the mitigation is present but incomplete (e.g., parameterized query but no length cap; auth check but no rate limit)
- **Consider** — defense-in-depth opportunity (e.g., add CSP header even though XSS is already escaped)

**When in doubt, default closed.** A handler with unclear authorization should deny, not allow. A deserializer with unclear input source should reject, not parse. A retry with unclear failure mode should stop, not loop.
