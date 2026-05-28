---
name: refactor-repo-structure
description: Refactors a Python project's directory structure to follow the src layout with uv. Works for both standalone packages and packages within a uv monorepo workspace. Does not modify any implementation code — only moves and reorganises files.
---

# Refactor Python Repo Structure

<what-to-do>

Refactor a Python project's directory structure to match the standard `src` layout, managed by `uv`.

Do not change implementation code. Only file locations, `pyproject.toml` configuration, and test directory placement are in scope.

</what-to-do>

<supporting-info>

## Step 1 — Detect the project type

Check whether the current target is one of the following:

- **Standalone package** — a single `pyproject.toml` at the root, with no workspace members.
- **Monorepo workspace** — a root `pyproject.toml` with `[tool.uv.workspace]` members pointing to sub-packages.

Ask the user to confirm if the project type is ambiguous.

## Step 2 — Audit the current structure

Walk the target package directory and note:

- Where source files currently live: flat root, `src/`, or another location.
- Where tests currently live: co-located, top-level `tests/`, or mixed.
- Whether a `pyproject.toml` exists and declares the package correctly.
- Whether a `Dockerfile` is present. If present, flag it because paths inside may need updating after the move.

Report the findings to the user before making any changes.

## Step 3 — Apply the target structure

For a **standalone package** or each **monorepo sub-package**, the target layout is:

```text
<package-root>/
├── Dockerfile (if present — do not modify contents)
├── pyproject.toml
├── src/
│   └── <package_name>/
│       ├── init.py
│       └── ... (all source modules)
└── tests/
    ├── init.py
    ├── unit/
    │   └── init.py
    └── integration/
        └── init.py
```

For a **monorepo**, the root also gets:

```text
<repo-root>/
├── pyproject.toml (workspace config)
├── conftest.py (shared fixtures — create if missing)
└── packages/
    └── <package-root>/ (as above)
```

Move files to match this layout. Do not rename any source files or alter their contents.

## Step 4 — Update `pyproject.toml`

Ensure each package's `pyproject.toml` contains:

- `[build-system]` using `hatchling` or `flit_core`.
- `[project]` with correct `name` and `version`.
- `[tool.pytest.ini_options]` with:
  - `testpaths = ["tests"]`
  - `addopts = "--import-mode=importlib -v --tb=short"`
  - `markers` for `unit` and `integration`.

For a monorepo root `pyproject.toml`, ensure:

- `[tool.uv.workspace]` lists all member packages.
- `[tool.pytest.ini_options]` has `testpaths` pointing at the packages directory.

## Step 5 — Verify nothing is broken

Run:

```bash
uv sync
uv run pytest --collect-only
```

Fix any import errors caused by the move before finishing.

Report any Dockerfile path references that may need manual review. Do not edit the Dockerfile automatically.

## Rules

- Never modify implementation code. Only move files and update config.
- Never delete files. If something does not fit the target structure, flag it for the user to decide.
- One package at a time in a monorepo. Ask which package to refactor if not specified.
- If tests already exist and their location is ambiguous, leave them in place and note it — the `refactor-tests` skill handles test reorganisation.

</supporting-info>
