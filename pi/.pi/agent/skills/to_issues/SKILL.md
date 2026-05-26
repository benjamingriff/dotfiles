---
name: to-issues
description: Break a PRD into independently-grabbable issue files in the same feature directory, using tracer-bullet vertical slices. Use when user wants to convert a PRD into issues, create implementation tasks, or break work into reviewable chunks.
---

# To Issues

Break a PRD into independently-grabbable issues using vertical slices (tracer bullets). Each issue becomes a markdown file in the same feature directory as the PRD.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. The user might reference a PRD either by path (e.g. `.scratch/2026-05-22-A3kF9pQ2/prd.md`) or implicitly via conversation context (a PRD was just written this session) which summarises the conversation context. It's important that you use this along with the conversation context to gather a full understand of the work.

### 2. Explore the codebase (if needed)

If you have not already explored the codebase in this session, do so now. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect any ADRs in the area you're touching.

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be **HITL** or **AFK**. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Write the issue files

For each approved slice, write a markdown file to `.scratch/<feature-slug>/issues/`. You should find the feature-slug from past context (e.g. 2026-05-22-A3kF9pQ2). If one can't be found, it's likely a prd doesn't exist. In this situation, create the uniquely-slugged directory under `.scratch/` in the repo root. Use this exact command so the slug combines today's date with a random suffix:

```bash
mkdir -p .scratch
SLUG_DIR=$(mktemp -d ".scratch/$(date +%Y-%m-%d)-XXXXXXXX")
echo "$SLUG_DIR"
```

**Naming and order:** number filenames in dependency order (blockers first) using a zero-padded two-digit prefix and a short kebab-case slug, e.g. `01-add-user-schema.md`, `02-login-endpoint.md`. This way `ls` shows the work in the order it should be done.

**Cross-references:**
- The **Parent** field links to the PRD as a relative path: `../prd.md`
- **Blocked by** entries reference sibling files by filename, e.g. `01-add-user-schema.md`

Use the issue body template below.

After writing all files, output the feature directory path and a summary list of the issues created, so the user can pick one to hand to a fresh agent.

<issue-template>
## Parent

[PRD](../prd.md)

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Type

HITL or AFK

## Blocked by

- `NN-other-issue.md`

Or "None — can start immediately" if no blockers.
</issue-template>
