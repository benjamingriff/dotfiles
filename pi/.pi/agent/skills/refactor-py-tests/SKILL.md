---
name: refactor-tests
description: "Refactors Python test files to follow a consistent structure: unit/integration folders, one test file per source file, classes grouping tests by behaviour, pytest markers, and conftest.py fixtures in the right place."
---

# Refactor Python Tests

<what-to-do>

Reorganise and rewrite a Python test suite so that it follows a consistent structure.

Tests should be split into `tests/unit/` and `tests/integration/`, mapped one-to-one with source files, grouped into behaviour-focused classes, marked with pytest markers, and supported by fixtures in the right `conftest.py` files.

Do not modify any source implementation files.

</what-to-do>

<supporting-info>

## Goal

Reorganise and rewrite the test suite so that:

- Tests are split into `tests/unit/` and `tests/integration/`.
- Each source file has exactly one corresponding test file.
- Tests within a file are grouped into classes by behaviour.
- Fixtures live in the right `conftest.py`.
- Both folder structure and pytest markers are used.

## Step 1 — Ask clarifying questions if needed

Before touching anything, check for ambiguity. Ask the user **one question at a time** if any of the following is unclear:

1. Is this a monorepo or standalone package? This determines whether to use a root `conftest.py`.
2. Are there existing tests? If yes, do they currently pass? Do not break passing tests.
3. Are there any fixtures or helpers already in a `conftest.py` that should be preserved?

Do not proceed past this step until you have answers.

## Step 2 — Audit the existing tests

Walk all existing test files. For each one, record:

- Which source file or files it appears to test.
- Whether its tests are unit-style: no I/O, no AWS calls.
- Whether its tests are integration-style: moto, boto3, real DB calls, or HTTP.
- Whether it uses any shared fixtures.
- Whether it is organised into classes or flat functions.

Summarise the findings and show the user the proposed mapping before making changes:

```text
tests/storage_test.py → tests/unit/test_storage.py (3 tests)
tests/storage_test.py → tests/integration/test_storage.py (2 tests)
```

Wait for approval before proceeding.

## Step 3 — Create the target directory structure

The target test layout is:

```text
tests/
├── init.py
├── unit/
│   ├── init.py
│   └── test_<module>.py (one per source file)
└── integration/
    ├── init.py
    └── test_<module>.py (one per source file)
```

For a **monorepo**, also ensure a root-level `conftest.py` exists for fixtures shared across packages. Each package may have its own `tests/conftest.py` for package-specific fixtures.

For a **standalone package**, a single `tests/conftest.py` is sufficient.

## Step 4 — Rewrite test files using classes

Each test file must follow this structure:

```python
# tests/unit/test_<module>.py

import pytest
from <package>.<module> import <Subject>


@pytest.mark.unit
class Test<Subject><Method>:
    """Tests for <what this class covers>."""

    def test_<behaviour>_when_<condition>(self):
        ...

    def test_raises_<error>_when_<condition>(self):
        ...


@pytest.mark.unit
class Test<Subject><OtherMethod>:
    ...
```

Rules for class grouping:

- One class per logical behaviour group, such as one public method or one distinct state.
- Class name = `Test` + `Subject` + `Behaviour`, for example `TestStorageClientPutItem`.
- Method names describe the expected outcome, for example `test_returns_none_when_item_not_found`.
- No flat test functions outside a class.

## Step 5 — Place fixtures correctly

Place fixtures according to their scope:

- Shared across packages in a monorepo: root `conftest.py`.
- Shared within a package: `tests/conftest.py`.
- Used in one file only: inline `@pytest.fixture` in that file.

Common fixtures to look for and centralise:

- Mock AWS credentials or environment variables.
- moto `mock_aws` context for DynamoDB, SQS, or S3.
- Lambda event and context stubs.
- Any shared model or schema factories.

Do not duplicate fixtures across `conftest.py` files.

## Step 6 — Add pytest markers

Mark every test class with either `@pytest.mark.unit` or `@pytest.mark.integration`. The folder already communicates this, but markers allow targeted runs from the repo root.

Ensure `pyproject.toml` declares the markers:

```toml
[tool.pytest.ini_options]
markers = [
    "unit: fast isolated tests with no external dependencies",
    "integration: tests using mocked or live AWS services",
]
```

## Step 7 — Verify

Run the following and fix any failures before finishing:

```bash
uv run pytest tests/unit -v
uv run pytest tests/integration -v
```

If a test is too tightly coupled to split cleanly into unit/integration, flag it for the user rather than guessing.

## Rules

- Never modify implementation code.
- Never delete tests. If a test does not have a clear home, flag it.
- One source file maps to one test file in each of `unit/` and `integration/`. Only create the integration file if integration tests exist for that module.
- Classes, not flat functions. Every test must live inside a class.
- Ask before acting if the existing test structure is ambiguous or if passing tests might break.

</supporting-info>
