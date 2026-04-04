---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/.env*"
---

# Python Security

## Secrets & Environment Variables

- Never hardcode secrets, API keys, tokens, or passwords in source code
- Load all sensitive values from environment variables via pydantic Settings
- Never commit `.env` files containing real credentials — use `.env.example` with placeholder values
- Add `.env` to `.gitignore` in every project

## Injection

- **SQL**: always use parameterized queries or ORM query builders — never string-format SQL
- **Command**: never pass user input to `subprocess`, `os.system`, `eval`, or `exec` without sanitization; prefer `subprocess.run` with a list of arguments (never `shell=True` with user input)
- **Template**: never pass user-controlled data into `str.format()` used as a template engine; use Jinja2 with autoescaping enabled for HTML

## Input Validation

- Validate all input at system boundaries: HTTP request bodies, CLI arguments, file uploads, external API responses
- Use Pydantic models at every API boundary — never pass raw dicts into domain logic
- Reject unexpected fields with `model_config = ConfigDict(extra="forbid")` where strictness matters
- Validate file paths: use `pathlib.Path.resolve()` and confirm the result is within the expected directory to prevent path traversal

## Sensitive Data Exposure

- Never log passwords, tokens, API keys, PII, or full request bodies containing sensitive fields
- Scrub sensitive fields before logging: redact or replace with `[REDACTED]`
- Do not include sensitive values in exception messages or error responses returned to clients
- Use `SecretStr` from pydantic for fields that must not appear in serialized output or logs

## Authentication & Authorization

- Never roll your own auth — use established libraries (e.g., `python-jose`, `passlib`, FastAPI's security utilities)
- Verify JWT signatures; never decode without verification (`decode(..., options={"verify_signature": False})` is forbidden in production)
- Check authorization on every endpoint — do not assume a valid token implies all permissions
- Use constant-time comparison (`hmac.compare_digest`) for secret comparison to prevent timing attacks

## Dependency Security

- Pin dependency versions in `pyproject.toml` and lock with `uv lock`
- Run `uv audit` (or `pip-audit`) in CI to catch known CVEs in dependencies
- Do not use `pickle` to deserialize untrusted data — use JSON or a safe schema-validated format instead
