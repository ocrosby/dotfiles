---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.ts"
  - "**/*.js"
  - "**/routes/**"
  - "**/handlers/**"
  - "**/controllers/**"
  - "**/views/**"
  - "**/api/**"
---

# REST API Conventions

All REST API code must conform to the principles defined at https://restfulapi.net/. These are mandatory constraints, not suggestions.

## Resource Naming

- URIs identify resources — use nouns, never verbs
- Collections use plural nouns: `/users`, `/managed-devices`
- Documents (single resource) use singular nouns: `/users/{id}`, `/users/admin`
- Hierarchical relationships use path segments: `/users/{id}/orders/{orderId}`
- No verbs in URIs — HTTP methods are the verbs:
  - `/users` not `/getUsers`
  - `/users/{id}` not `/deleteUser/{id}`
  - `/orders/{id}/cancel` is a violation — use `DELETE /orders/{id}` or model as a sub-resource
- Lowercase letters only: `/managed-devices` not `/managedDevices`
- Hyphens for readability, not underscores: `/managed-devices` not `/managed_devices`
- No trailing slashes: `/users` not `/users/`
- No file extensions: `/users` not `/users.json`
- Query parameters for filtering, sorting, and pagination — not path segments:
  - `/users?status=active&sort=name` not `/users/active/sorted-by-name`

## HTTP Methods

Use methods according to their defined semantics. Misuse is a contract violation.

| Method | Semantics | Safe | Idempotent |
|--------|-----------|------|------------|
| GET    | Retrieve resource(s) — must not modify state | Yes | Yes |
| POST   | Create a new subordinate resource | No | No |
| PUT    | Replace an existing resource entirely | No | Yes |
| PATCH  | Apply partial modifications to a resource | No | No* |
| DELETE | Remove a resource | No | Yes |

*PATCH idempotency depends on the operation — document intent explicitly.

Rules:
- GET must never modify server state — no side effects
- POST creating a resource must return `201 Created` with a `Location` header
- PUT must replace the entire resource representation — use PATCH for partial updates
- Repeated PUT and DELETE requests must produce the same outcome as a single request
- Do not tunnel actions through GET query parameters: `GET /users?action=delete` is forbidden

## HTTP Status Codes

Return the most specific applicable status code. Never hide errors in a `200 OK` response body.

### Success (2xx)

- `200 OK` — successful GET, PUT, PATCH, DELETE with response body
- `201 Created` — resource created via POST; **must** include `Location` header with new resource URI
- `202 Accepted` — request accepted but not yet processed (async operations)
- `204 No Content` — successful PUT, PATCH, DELETE with no response body; **must not** include a body
- `206 Partial Content` — response to a `Range` request

### Redirection (3xx)

- `301 Moved Permanently` — use sparingly; prefer API versioning (`/v1/`, `/v2/`) over redirects
- `304 Not Modified` — use with `ETag`/`If-None-Match` or `Last-Modified`/`If-Modified-Since` for caching

### Client Errors (4xx)

- `400 Bad Request` — malformed syntax, invalid parameters; client must not repeat unchanged
- `401 Unauthorized` — missing or invalid credentials; response must include `WWW-Authenticate` header
- `403 Forbidden` — identity is known but access is denied; authentication will not help
- `404 Not Found` — resource does not exist (may exist later); use `410 Gone` for permanently deleted
- `405 Method Not Allowed` — HTTP method not supported; response must include `Allow` header
- `406 Not Acceptable` — cannot produce the requested media type (`Accept` header)
- `409 Conflict` — state conflict (e.g., duplicate create, optimistic locking failure)
- `412 Precondition Failed` — conditional request headers (`If-Match`, etc.) not satisfied
- `415 Unsupported Media Type` — cannot process the supplied `Content-Type`
- `422 Unprocessable Entity` — syntax valid but semantically incorrect (validation errors)
- `429 Too Many Requests` — rate limit exceeded

### Server Errors (5xx)

- `500 Internal Server Error` — unexpected server failure; never the client's fault
- `503 Service Unavailable` — server temporarily unavailable; client may retry

### Anti-Patterns (violations)

- `200 OK` with an error message in the body — use the appropriate 4xx/5xx code
- `201 Created` without a `Location` header
- `204 No Content` with a response body
- Conflating `401` and `403` — they have distinct meanings
- Using `302 Found` for non-idempotent redirects — use `307 Temporary Redirect` to preserve method

## Statelessness

Every request must contain all information needed to process it. The server must not store client session state between requests.

- Do not use server-side sessions to maintain client context
- Authentication state must be carried in each request (e.g., Bearer token, API key)
- Any state required between calls must be managed by the client

## Uniform Interface

- Each resource has a single, stable URI
- Resources are manipulated through representations (JSON, XML) — not direct object references
- Responses should include hypermedia links where they enable state transitions (HATEOAS)
- Media type definitions describe how to process representations

## Caching

- Responses must explicitly indicate cacheability via `Cache-Control`, `ETag`, or `Last-Modified`
- GET and HEAD responses are cacheable by default unless instructed otherwise
- POST, PUT, PATCH, DELETE responses are not cacheable unless explicitly marked

## Versioning

- Version the API when breaking changes are introduced
- Prefer URI path versioning: `/v1/users`, `/v2/users`
- Do not silently change behavior under the same URI
