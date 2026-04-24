---
name: erdac-schema-design
description: Use ERDaC to collaboratively design SQL data models by editing local schema files and config, then review the result in the live ERD UI.
---

# ERDaC Schema Design

Use this skill when the user wants to design or revise a SQL schema and review the result in ERDaC.

## ERDaC Mental Model

ERDaC renders a live ERD from local SQL files.

- SQL files define structure.
- `diagram.config.yaml` tells ERDaC where to read schema files and which named views to offer.
- `.erdac/layout.json` stores visual positions only.

Treat the diagram as a projection of code, not a separate source of truth.

## Default Workflow

When using ERDaC for schema design:

1. Look for the relevant `diagram.config.yaml` near the part of the codebase the user is working on, and search the wider codebase if needed.
2. Read its `entry` value to find the SQL source directory or file.
3. Edit SQL under that configured path to add or change tables, columns, primary keys, and foreign keys.
4. If the design should be easier to review, add or refine a named view in `diagram.config.yaml`.
5. Let the running ERDaC UI render the updated design.

Do not assume the config is always in the current directory or a parent.

- First, look for a nearby `diagram.config.yaml` relative to the schema or app the user is working on.
- If it is not there, search the codebase for `diagram.config.yaml` files.
- If multiple configs exist, prefer the one closest to the relevant schema files or the area the user asked you to work in.
- Treat the chosen config's `entry` value as the source location for schema edits.

Default to SQL and config changes only.

## How To Tell If ERDaC Is Already Set Up

`erdac init` usually creates these project markers:

- `diagram.config.yaml`
- `schema/`
- `.erdac/`

Strong signs ERDaC has already been initialized in a given project area:

- a `diagram.config.yaml` file exists nearby or elsewhere in the codebase
- the configured `entry` path exists
- there is a `.erdac/` directory
- there are `.sql` files under the configured schema path

If these are missing, the project may not be initialized yet.

To bootstrap a new project:

```bash
erdac init
erdac dev
```

After initialization, review `diagram.config.yaml` and edit files in the configured schema directory.

## What To Edit

- SQL files under the configured `entry` path
- `diagram.config.yaml` when you need to add or refine named views

Use named views to make a proposal easier to inspect, for example:

```yaml
entry: ./schema
layout: auto
views:
  - name: billing
    include: ["customers", "subscriptions", "invoices"]
```

## What Not To Edit By Default

- `.erdac/layout.json` to represent schema logic
- ERDaC UI/application code just to make a schema visible
- generated screenshots or exports unless the user asks for them

## SQL Guidance

Prefer straightforward, Postgres-style `CREATE TABLE` DDL that is easy to parse into an ERD.

- make primary keys explicit
- make foreign keys explicit
- use clear table and column names
- prefer simple, readable definitions over clever SQL

If a design can be expressed with standard `CREATE TABLE` statements and explicit references, prefer that form.

## Presenting A Design In ERDaC

When the user wants to review a proposal:

- update the SQL model first
- add a focused named view if the schema is large
- keep related tables grouped in that view
- rely on ERDaC's existing search, focus, and view controls rather than changing the UI

Named views are often the best way to show a design clearly without extra app work.

## Verification Checklist

After making changes, verify that:

1. ERDaC starts or is already running.
2. The SQL parses without unexpected diagnostics.
3. The expected tables appear in the diagram.
4. The expected relationships appear in the diagram.
5. Any added named view isolates the intended subset cleanly.

## Guardrails

- Keep SQL as the source of truth.
- Prefer minimal schema and config changes.
- Use `diagram.config.yaml` to shape review workflows.
- Do not use layout files to encode model structure.
- Do not edit ERDaC internals unless the task is explicitly about ERDAC itself.
