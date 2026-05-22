---
name: to-prd
description: Turn the current conversation context into a PRD and save it to a scratch directory in the current repo. Use when user wants to create a PRD from the current context.
---

# To PRD

This skill takes the current conversation context and codebase understanding and produces a PRD as a local markdown file. Do NOT interview the user — just synthesize what you already know.

## Process

### 1. Explore the repo

If you have not already done so, explore the repo to understand the current state of the codebase. Use the project's domain glossary vocabulary (reference CONTEXT.md) throughout the PRD, and respect any ADRs in the area you're touching.

### 2. Sketch the modules

Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

### 3. Create the feature directory

Create a uniquely-slugged directory under `.scratch/` in the repo root. Use this exact command so the slug combines today's date with a random suffix:

```bash
mkdir -p .scratch
SLUG_DIR=$(mktemp -d ".scratch/$(date +%Y-%m-%d)-XXXXXXXX")
echo "$SLUG_DIR"
```

The resulting path (e.g. `.scratch/2026-05-22-A3kF9pQ2`) is the feature directory. The `to-issues` skill will write issues into this same directory.

### 4. Write the PRD

Write the PRD to `$SLUG_DIR/prd.md` using the template below.

### 5. Report the path

After writing, output the absolute path to `prd.md` so the user can pass it to `to-issues` or another agent.

<prd-template>
## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.
</prd-template>
