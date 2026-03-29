---
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Go Project Architecture

## Structure

### Server applications

```
project-name/
├── cmd/
│   └── server/
│       └── main.go          -- entry point, wiring, startup
├── internal/
│   ├── config/
│   │   └── config.go        -- env/flag parsing, validation
│   ├── domain/
│   │   ├── models.go        -- core types and entities
│   │   └── services.go      -- business logic, use cases
│   ├── ports/
│   │   ├── repositories.go  -- storage interfaces
│   │   └── clients.go       -- external service interfaces
│   └── adapters/
│       ├── http/
│       │   ├── server.go    -- HTTP server setup, middleware
│       │   ├── routes.go    -- route registration
│       │   └── handlers.go  -- request handlers
│       ├── db/
│       │   └── postgres.go  -- database repository implementations
│       └── external/
│           └── client.go    -- third-party API clients
├── go.mod
└── go.sum
```

### CLI applications

```
project-name/
├── cmd/
│   └── tool/
│       └── main.go
├── internal/
│   ├── config/
│   ├── core/               -- business logic
│   └── adapters/
├── go.mod
└── go.sum
```

## Module Responsibilities

- **cmd/**: entry points only — parse config, wire dependencies, start the application
- **internal/domain/**: pure business logic — no external imports beyond stdlib
- **internal/ports/**: interfaces defining how domain interacts with the outside world
- **internal/adapters/**: concrete implementations of ports
- **internal/config/**: configuration parsing and validation

## Design Rules

- `internal/` for all non-public packages — prevents external imports
- `cmd/` packages are thin: create dependencies, wire them together, call `Run()`
- Domain imports nothing from adapters — dependency direction flows inward
- One package per concern — split when a file exceeds 500 lines
- Accept interfaces in function parameters, return concrete types
- Constructor functions (`New...`) accept dependencies and return the struct
- Use `context.Context` as the first parameter on all methods that do I/O
