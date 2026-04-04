---
description: Guides development of new Python features following hexagonal architecture and clean code principles.
triggers:
  - /py-feature
paths:
  - "**/*.py"
---

# Python Feature Development

## Workflow

### 1. Understand the Feature

- Clarify what the feature does from the user's perspective
- Identify which layer it belongs to: domain, port, adapter, or application
- Determine if it needs new API endpoints, CLI commands, MCP tools, or background tasks

### 2. Design the Interface

- Define the public API: functions, classes, and their signatures with full type hints
- Design configuration with pydantic Settings if new config is needed
- Plan the request/response models with Pydantic `BaseModel`

> For features that introduce new modules, ports, or significant domain abstractions, invoke `/architect` before implementing to get a comprehensive structural proposal.

### 3. Implement (Domain First)

- Start with domain models and services — pure Python, no framework imports
- Define ports (Protocol classes) for any new external dependencies
- Implement adapters: FastAPI routes, DB repositories, API clients
- Wire dependencies via injection (`Depends()` in FastAPI, constructor injection elsewhere)

### 4. Structure

- One module per concern — split at 300 lines
- Domain logic has no I/O, no framework imports
- Adapters are thin: validate input, delegate to domain, return result
- FastAPI routes use `APIRouter`, one router per domain area
- FastMCP tools use `@mcp.tool()` with type hints and docstrings for schema derivation

### 5. FastAPI Specifics

- Define request/response models with Pydantic `BaseModel`
- Use `Depends()` for shared logic (auth, DB sessions, config)
- Use `lifespan` context manager for startup/shutdown, not `on_event`
- Return explicit status codes (`status_code=201` for creation)
- Use `HTTPException` for error responses with appropriate status codes

### 6. FastMCP Specifics

- Declare tools with `@mcp.tool()`, resources with `@mcp.resource()`
- Tool functions derive their schema from type hints and docstrings
- Keep tool functions thin: validate, delegate to domain, return
- Use `Context` for logging and progress reporting

### 7. Review Checklist

- [ ] Type hints on all function signatures and class attributes
- [ ] Domain logic is pure — no framework or I/O imports
- [ ] Dependencies injected, not hardcoded
- [ ] Pydantic models for all API boundaries
- [ ] Error cases raise domain-specific exceptions
- [ ] No global mutable state
