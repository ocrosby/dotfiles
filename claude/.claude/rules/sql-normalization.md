---
paths:
  - "**/*.sql"
  - "**/migrations/**/*.py"
  - "**/migrations/**/*.go"
  - "**/models/**/*.py"
  - "**/models/**/*.go"
  - "**/models.py"
  - "**/entities/**/*.py"
  - "**/entities/**/*.go"
  - "**/schema.py"
  - "**/schema.go"
  - "**/*_schema.go"
  - "**/*_schema.py"
  - "**/*_model.go"
  - "**/*_model.py"
  - "**/*_entity.go"
  - "**/*_entity.py"
---

# Database Normalization

All data model definitions must target Third Normal Form (3NF) by default. Violations must be explicit, documented, and justified as performance trade-offs — never accidental.

## Core Concepts

**Functional dependency**: attribute B is functionally dependent on attribute A when each value of A determines exactly one value of B. Written A → B.

**Candidate key**: the minimal set of attributes that uniquely identifies each row. A table may have multiple candidate keys; one is designated the primary key.

**Partial dependency**: a non-key attribute depends on only part of a composite candidate key (2NF violation).

**Transitive dependency**: a non-key attribute depends on another non-key attribute rather than directly on the key (3NF violation).

## Normal Forms

### First Normal Form (1NF)
Every cell contains a single, atomic value — no repeating groups, no arrays, no comma-separated lists.

```sql
-- Violation: phone_numbers is multi-valued
CREATE TABLE contacts (
    id          INT PRIMARY KEY,
    name        TEXT,
    phone_numbers TEXT  -- "555-1234, 555-5678"
);

-- Correct: extract to a child table
CREATE TABLE contacts (
    id   INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE contact_phones (
    contact_id INT REFERENCES contacts(id),
    phone      TEXT,
    PRIMARY KEY (contact_id, phone)
);
```

### Second Normal Form (2NF)
Every non-key attribute must depend on the *entire* candidate key — not a subset of it. Only relevant when the candidate key is composite.

```sql
-- Violation: supplier_name depends only on supplier_id, not on (part_id, supplier_id)
CREATE TABLE supply (
    part_id       INT,
    supplier_id   INT,
    supplier_name TEXT,  -- partial dependency on supplier_id alone
    unit_cost     NUMERIC,
    PRIMARY KEY (part_id, supplier_id)
);

-- Correct: move supplier_name to the suppliers table
CREATE TABLE suppliers (
    id   INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE supply (
    part_id     INT,
    supplier_id INT REFERENCES suppliers(id),
    unit_cost   NUMERIC,
    PRIMARY KEY (part_id, supplier_id)
);
```

### Third Normal Form (3NF)
No non-key attribute may depend on another non-key attribute. Eliminates transitive dependencies.

```sql
-- Violation: zip_code → city (city depends on zip_code, not on employee_id)
CREATE TABLE employees (
    id       INT PRIMARY KEY,
    name     TEXT,
    zip_code TEXT,
    city     TEXT  -- transitive dependency through zip_code
);

-- Correct: extract the transitive dependency
CREATE TABLE zip_codes (
    zip  TEXT PRIMARY KEY,
    city TEXT
);
CREATE TABLE employees (
    id       INT PRIMARY KEY,
    name     TEXT,
    zip_code TEXT REFERENCES zip_codes(zip)
);
```

### Boyce-Codd Normal Form (BCNF)
Every determinant must be a candidate key. Stricter than 3NF; resolves anomalies when a table has overlapping composite candidate keys.

Apply BCNF when a table has multiple overlapping candidate keys and a non-key attribute determines part of one of them.

## Data Anomalies — What Normalization Prevents

**Update anomaly**: the same fact appears in multiple rows; an incomplete update leaves the database inconsistent.

**Insertion anomaly**: a fact cannot be recorded without also recording an unrelated fact (e.g., a supplier cannot be added until they supply at least one part).

**Deletion anomaly**: deleting one fact unintentionally destroys another (e.g., deleting the last order for a supplier also deletes the supplier's contact information).

If any of these anomalies are possible in a schema, the schema is under-normalized.

## Design Rules

- Target **3NF for all OLTP schemas** (transactional systems, APIs, services).
- Each table models exactly one entity or relationship — not a mixture of both.
- Foreign keys enforce referential integrity at the schema level, not only in application code.
- Every table must have a candidate key. Surrogate keys (`id SERIAL PRIMARY KEY`) are acceptable, but must not replace natural candidate keys when they exist — declare `UNIQUE` constraints on natural keys.
- Column names must be unambiguous without the table name: `users.email` not `users.user_email`.
- Avoid nullable columns for attributes that are always present — `NOT NULL` should be the default, `NULL` the exception.
- Never store derived values (sums, counts, concatenations) as persisted columns unless benchmarked performance requires it and the denormalization is documented.

## Denormalization

Denormalization is a deliberate performance optimization, not a design shortcut. It is only acceptable when:

1. A normalized query has been profiled and proven to be a bottleneck.
2. The specific redundancy introduced is documented with a comment explaining which normal form is violated and why.
3. The application layer enforces consistency (e.g., triggers, application-level invariants, or event-driven synchronization).

```sql
-- Intentional denormalization: orders.customer_email duplicates users.email
-- to avoid a join on the hot order-fetch path. Kept in sync by the
-- user_email_changed event handler. Violates 3NF deliberately.
ALTER TABLE orders ADD COLUMN customer_email TEXT;
```

OLAP / data warehouse schemas (star schema, snowflake schema) intentionally denormalize for query performance and columnar compression — this is expected and does not require justification beyond the schema type.

## Higher Normal Forms (reference)

**Fourth Normal Form (4NF)**: no non-trivial multivalued dependencies. Relevant when a table records independent multi-valued facts about the same key.

**Fifth Normal Form (5NF)**: all join dependencies are implied by candidate keys. Rarely encountered outside academic contexts.

Apply 4NF or 5NF only when multi-valued or join-dependency anomalies are confirmed — not speculatively.
