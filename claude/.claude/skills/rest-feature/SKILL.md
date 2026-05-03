---
description: Guides development of new REST API endpoints following OpenAPI-first design and REST conventions.
triggers:
  - /rest-feature
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.ts"
  - "**/*.js"
---

# REST Feature Development

## Workflow

### 1. Understand the Feature

- Clarify what resource is being exposed or modified
- Identify the HTTP method and URI pattern using REST naming rules:
  - Collection operations → `GET /resources`, `POST /resources`
  - Document operations → `GET /resources/{id}`, `PUT /resources/{id}`, `PATCH /resources/{id}`, `DELETE /resources/{id}`
  - No verbs in paths — HTTP methods are the verbs
- Determine whether this is a new resource, a new operation on an existing resource, or a breaking change requiring a new version prefix (`/v2/`)

> For features that introduce a significant new resource hierarchy or cross-cutting API concerns, run `/architect` first to get a structural proposal before writing any handler code.

### 2. Design the Endpoint (spec first)

Write the OpenAPI specification for the endpoint **before writing any handler code**. This is design-first: the spec is the contract; the implementation follows from it.

If no OpenAPI spec file exists in the project, create `openapi.yaml` at the project root with a minimal OpenAPI 3.0 header before adding the endpoint:

```yaml
openapi: "3.0.3"
info:
  title: API
  version: "1.0.0"
paths: {}
components:
  schemas: {}
  responses: {}
```

For a new endpoint, add to `openapi.yaml` (or the project's existing spec file):

```yaml
/users/{id}/orders:
  get:
    operationId: listUserOrders
    summary: List orders for a user
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
      - name: status
        in: query
        schema:
          type: string
          enum: [pending, fulfilled, cancelled]
    responses:
      "200":
        description: Paginated list of orders
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/OrderList"
      "401":
        $ref: "#/components/responses/Unauthorized"
      "404":
        $ref: "#/components/responses/NotFound"
```

Validate the spec design against `rest-api-conventions.md` before proceeding:
- URI is a noun, lowercase, hyphens for multi-word segments
- Correct HTTP method semantics
- Correct status codes (`201 Created` + `Location` header for POST creating a resource)
- No verbs in the path
- Filtering/sorting/pagination in query params, not path segments

### 3. Define the Request and Response Shapes

Before implementing the handler, define the data types that the endpoint accepts and returns.

**Go:**
```go
// Request: bind from path params and query params — no body for GET
type ListUserOrdersParams struct {
    UserID string
    Status string // optional query param
}

// Response
type OrderList struct {
    Items  []Order `json:"items"`
    Total  int     `json:"total"`
    Cursor string  `json:"cursor,omitempty"`
}
```

**Python (FastAPI + Pydantic):**
```python
class OrderListResponse(BaseModel):
    items: list[Order]
    total: int
    cursor: str | None = None
```

### 4. Implement (TDD — Handler Last)

Follow the red-green-refactor cycle. Work domain-outward:

1. **Domain/service layer first** — write the business logic as a pure function or method with no HTTP concern:
   ```go
   // ListUserOrders(ctx, userID, status) → ([]Order, error)
   ```
   Write the test, make it pass, refactor.

2. **Port interface** — define the interface the handler will call through (if needed for the service-to-adapter boundary).

3. **HTTP handler last** — the handler is thin:
   - Parse request (path params, query params, body)
   - Validate input: `400 Bad Request` for malformed syntax (missing required field, invalid JSON, wrong query param type); `422 Unprocessable Entity` for semantically invalid values (enum violation, domain rule failure)
   - Call the domain/service method
   - Map the result to the response shape and status code
   - Write the response

The handler must contain no business logic — only parse → delegate → respond. Never write the handler before the domain method exists. The order is always: (1) domain function and its tests, (2) port interface if an external dependency needs adapting, (3) HTTP handler last.

### 5. Status Code Checklist

Apply this before committing any handler:

| Condition | Required status code |
|---|---|
| POST created a new resource | `201 Created` + `Location: /resources/{id}` header |
| Successful GET/PUT/PATCH with body | `200 OK` |
| Successful DELETE or no-content response | `204 No Content` (no body) |
| Resource not found | `404 Not Found` |
| Invalid credentials or missing auth | `401 Unauthorized` + `WWW-Authenticate` header |
| Valid identity, insufficient permission | `403 Forbidden` |
| Semantic validation failure | `422 Unprocessable Entity` |
| Malformed request syntax | `400 Bad Request` |
| Method not supported on this resource | `405 Method Not Allowed` + `Allow` header |

### 6. Review

After implementation, run `/code-review` on the changed files. The skill automatically invokes the `rest-reviewer` agent on any file containing route registrations — no extra step needed.

The reviewer checks:
- URI naming conventions
- HTTP method semantics
- Status code correctness
- Statelessness
- Caching headers on GET responses

### 7. Review Checklist

- [ ] Endpoint is documented in the OpenAPI spec before the handler was written
- [ ] URI uses nouns, plural for collections, lowercase, hyphens for multi-word segments
- [ ] HTTP method matches the operation semantics (no GET with side effects)
- [ ] POST returning 201 includes a `Location` header
- [ ] Handler contains no business logic — all logic lives in the domain/service layer
- [ ] Validation failures return 422, not 400
- [ ] 401 vs 403 are not conflated
- [ ] GET responses set `Cache-Control` or `ETag` where appropriate
- [ ] Breaking changes use a new version prefix (`/v2/`) rather than mutating the existing URI

## Rules

- Always write the OpenAPI spec entry before writing any handler code — the spec is the contract
- Never put business logic in the handler — parse, delegate, respond
- If the feature introduces a new version prefix or a new top-level resource hierarchy, run `/architect` first
- Follow `rest-api-conventions.md` for all status code and header requirements — that file is the authoritative reference; do not duplicate its rules here
