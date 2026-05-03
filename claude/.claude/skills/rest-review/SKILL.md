---
description: Reviews HTTP handler and route code for REST API convention compliance — resource naming, HTTP methods, status codes, statelessness, and caching.
triggers:
  - /rest-review
---

# REST Review

Use this skill when reviewing any code that defines HTTP endpoints — handlers, routers, controllers, or route definitions — to check for REST convention compliance.

## When to use

Invoke `/rest-review` after implementing or modifying HTTP endpoint code, before opening a PR, or when a code review surfaces REST design questions. Do not invoke on non-HTTP code (business logic, domain models, repositories).

`/code-review` routes to `rest-reviewer` automatically when HTTP patterns are detected. Use `/rest-review` directly when you want an isolated REST compliance review without a full language-level review.

## Workflow

### 1. Identify HTTP endpoint files

Search the working tree for files that define HTTP routes or handlers:

```bash
# Go
grep -rl "http.HandleFunc\|router\.\(GET\|POST\|PUT\|PATCH\|DELETE\|Handle\)\|gin\.\|echo\.\|chi\.\|mux\." --include="*.go" .

# Python
grep -rl "@app\.\|@router\.\|APIRouter\|@.*\.route\|FastAPI\|Flask" --include="*.py" .

# TypeScript/JavaScript
grep -rl "router\.\|app\.\(get\|post\|put\|patch\|delete\)\|express\(\)\|Hono\|Fastify" --include="*.ts" --include="*.js" .
```

If `$ARGUMENTS` names a specific file or directory, review only that path. Otherwise review all discovered endpoint files in the current working directory.

If no HTTP endpoint files are found, report "No HTTP endpoint definitions found in the current working tree." and stop.

### 2. Delegate to rest-reviewer agent

Invoke the `rest-reviewer` agent with the list of endpoint files discovered in step 1. Pass the full file paths and enough context about the project's API surface for the agent to make accurate assessments.

### 3. Report findings

Present the agent's findings using the three-severity format:

- **Must Fix** — violates REST constraints that will cause interoperability or correctness problems (wrong status codes, unsafe methods used for mutations, state stored server-side between requests)
- **Should Fix** — convention violations that hurt API usability or discoverability (non-resource URL paths, missing or incorrect `Content-Type`, inconsistent pluralization)
- **Consider** — improvements that make the API more idiomatic (HATEOAS links, ETag/caching headers, versioning strategy)

Group findings by file. If no issues are found, say so explicitly.
