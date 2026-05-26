---
name: code-review
description: Interactive post-implementation code review. Reviews changes introduced by the current implementation against the task/issue spec, surfacing findings one at a time in order of downstream impact. Use after implementing a feature or fix — either in the same context window, or reviewing a diff and issue definition. Covers correctness, architecture, security, performance, readability, and dead code. Does NOT silently modify code.
---

# Code Review

<what-to-do>

Run an interactive, issue-by-issue review of code changes after implementation.

First audit the full change silently. Then surface findings in downstream-impact order, one at a time. Do not move to the next finding until the current one is resolved: fixed, dismissed, explicitly deferred, or judged not applicable by the user.

Do not silently modify code during the review. Only edit code after the user explicitly asks you to fix a surfaced finding.

</what-to-do>

<supporting-info>

## Input modes

### Same-context mode

Use this mode when invoked directly after implementation in the same context window. The agent already knows what was implemented and why.

Examples:

> Review what you just implemented.
> Review what you just implemented — it's similar in structure to the billing module, assess against that.

### Diff mode

Use this mode when invoked with explicit inputs, usually after a context reset or for a larger feature.

Examples:

> Review this PR. Here's the diff: [...] Here's the issue: [...]
> Review this diff. The feature should do X and Y.

If no spec or issue is provided, infer intent from the code, tests, filenames, and commit messages. Flag any important ambiguity as part of the review.

## Review process

### Phase 1: Silent full audit

Before surfacing anything, perform a complete internal review of the changes. Do not output findings yet.

#### Scope

- In same-context mode, review everything you implemented.
- In diff mode, review only changed files in the diff.
- Do not review unrelated code except when needed to understand patterns, dependencies, or architectural drift.

#### Audit axes

1. **Correctness** — Does the code do what the spec/task requires? Are edge cases and error paths handled? Are there off-by-one errors, race conditions, or broken assumptions?
2. **Architecture** — Do the changes follow existing patterns? Are module boundaries respected? Do dependencies flow in the right direction? If a reference module/component is provided, explicitly compare structure, naming, and patterns.
3. **Security** — Is user input validated at boundaries? Are secrets kept out of code and logs? Are queries parameterised? Is external data treated as untrusted before use in logic or rendering?
4. **Performance** — Any N+1 query patterns, unbounded loops, unconstrained data fetching, missing pagination, large objects in hot paths, or synchronous operations that should be async?
5. **Readability & simplicity** — Are names clear and consistent with project conventions? Is control flow straightforward? Are abstractions earning their complexity? Could this be done in meaningfully fewer lines?
6. **Dead code** — Did the implementation introduce unreachable or unused code? Did it replace something that is now orphaned? Do not silently remove anything; flag it explicitly.

#### Architectural drift check

Always do a lightweight architectural drift pass, even if no reference is given. Look for:

- Inconsistent patterns compared to equivalent modules
- New abstractions that duplicate existing ones
- Dependencies that conflict with the existing stack
- Naming, error handling, testing, or file-structure drift

If a reference module or component is explicitly provided, do a deeper comparison.

### Phase 2: Classify and order findings

Classify every finding before surfacing it.

| Severity | Meaning |
|---|---|
| **Critical** | Blocks merge. Data loss, security vulnerability, broken functionality, or spec not met. |
| **Important** | Should be fixed before merge. Architectural drift, meaningful readability problems, or performance issues with real impact. |
| **Nit** | Minor and optional. Style preferences or small naming inconsistencies. The author may dismiss freely. |
| **FYI** | Informational only. No action needed; useful context for future work. |

Sort findings by downstream impact:

1. Critical correctness/spec failures
2. Architectural or structural issues
3. Security issues
4. Performance issues
5. Readability and simplicity issues
6. Dead code
7. Nits
8. FYIs

If a critical or architectural issue would require a full rewrite, say so explicitly so the user can stop the review, fix it, and rerun.

### Phase 3: Work through findings

Present one finding at a time, starting with the highest downstream impact. Explain the issue, why it matters, and the most appropriate recommendation. Include enough implementation detail for the user to judge whether the approach is right, then wait for their response.

Do not move to the next finding until the current finding is resolved. A finding is resolved when the user dismisses it, explicitly defers it, decides no change is needed, or asks for a fix and the fix has been completed and accepted.

If the user asks you to fix a finding:

1. Make the most appropriate targeted change for the problem, consistent with the codebase's existing patterns. Do not under-fix just to minimise the diff.
2. Run relevant checks if available and appropriate.
3. Summarise what changed, why that approach was chosen, and whether checks passed. Include easy-to-find references such as file names, line numbers, relevant function signatures, and test names changed.
4. Ask whether the finding is resolved before continuing.

If there are no findings, say so clearly and briefly. Mention any residual uncertainty caused by missing spec, unavailable tests, or incomplete context.

If the user dismisses a finding, accept the dismissal and continue. Do not argue unless the dismissal would leave a critical correctness or security issue unresolved; in that case, briefly restate the risk once, then respect the user's decision.

## Review stance

Be direct, specific, and evidence-led. Avoid vague feedback like "this could be cleaner" unless you can explain the concrete impact and a practical improvement.

Prefer findings that matter to correctness, maintainability, or future change cost. Do not pad the review with low-value style comments.

</supporting-info>
