---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---

# Python Project Architecture

## Structure

### Server applications (FastAPI / FastMCP)

```
project-name/
├── src/project_name/
│   ├── __init__.py
│   ├── main.py              -- app factory, lifespan, router includes
│   ├── config.py            -- pydantic Settings, env loading
│   ├── domain/              -- pure business logic, no framework imports
│   │   ├── models.py        -- domain entities (dataclasses or Pydantic)
│   │   └── services.py      -- use cases, orchestration
│   ├── ports/               -- abstract interfaces (Protocol classes)
│   │   ├── repositories.py
│   │   └── clients.py
│   ├── adapters/            -- concrete implementations
│   │   ├── api/             -- FastAPI routers (driving adapters)
│   │   │   ├── routes.py
│   │   │   └── deps.py      -- Depends() providers
│   │   ├── db/              -- database repositories (driven adapters)
│   │   └── external/        -- third-party API clients (driven adapters)
│   └── mcp/                 -- FastMCP server and tools (if applicable)
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml
└── uv.lock
```

### CLI applications

```
project-name/
├── src/project_name/
│   ├── __init__.py
│   ├── cli.py               -- click group and commands
│   ├── config.py
│   ├── core/                -- business logic
│   └── adapters/            -- external integrations
├── tests/
├── pyproject.toml
└── uv.lock
```

## Module Responsibilities

- **main.py**: app factory, lifespan context manager, router registration — no business logic
- **config.py**: single `Settings` class using pydantic-settings, loaded from environment
- **domain/**: pure Python — no framework imports, no I/O, fully testable in isolation
- **ports/**: Protocol classes defining interfaces for driven adapters
- **adapters/**: concrete implementations — FastAPI routes, DB repos, API clients
- **mcp/**: FastMCP server, tool definitions — thin wrappers delegating to domain services

## Design Rules

- One module per concern — split when a file exceeds 300 lines
- Dependency direction flows inward: adapters → ports → domain
- Domain layer imports nothing from adapters or framework
- Use dependency injection everywhere — `Depends()` in FastAPI, constructor injection elsewhere
- Configuration via pydantic Settings, never hardcoded values
- Use `src/` layout with `pyproject.toml` — never flat layout
