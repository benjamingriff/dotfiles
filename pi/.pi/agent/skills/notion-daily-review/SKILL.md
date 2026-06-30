---
name: notion-daily-review
description: Append to and tidy Benjamin's Daily review section in today's Notion daily note using ntn. Use when the user says they have been working on something, wants to capture a point-in-time work reflection, add daily review content, or clean up/consolidate today's Daily review.
---

# Notion Daily Review

Use this skill when digiben asks to capture a short work reflection into today's Notion daily note, especially prompts like:

- “I've been working on this…”
- “add this to my daily review”
- “capture this in today's review”
- “clean up my daily review”
- “turn today's snippets into a proper daily review”

This skill is intentionally small: find today's `Daily Notes - DD/MM/YYYY` page, locate the `### Daily review` section near the bottom, and either append freeform content or consolidate the section.

## Requirements

- Use the `ntn` CLI for Notion access.
- First check that `ntn` exists and is authenticated:

```bash
command -v ntn
ntn whoami
```

If either fails, tell the user what failed and stop.

## Date conventions

- Use the current system date unless the user specifies another date.
- Daily titles use `DD/MM/YYYY`, e.g. `Daily Notes - 30/06/2026`.
- If the user says “today”, calculate: `Daily Notes - DD/MM/YYYY`.

## Workflow

### 1. Find the daily note

Search for the exact daily note title first:

```bash
ntn api /v1/search -d '{"query":"Daily Notes - DD/MM/YYYY","page_size":10}'
```

Choose the exact matching page title. If there is no exact match, search recent daily notes:

```bash
ntn api /v1/search -d '{"query":"Daily Notes","page_size":20}'
```

If the correct note is still unclear, ask the user rather than creating a new page. This skill should not create daily notes; use the `notion-daily-notes` skill for that.

Fetch the page Markdown:

```bash
ntn pages get <page-id>
```

### 2. Locate `Daily review`

Find the section headed exactly or approximately:

```md
### Daily review
```

Treat the daily review body as everything after that heading until the next heading of the same or higher level (`#`, `##`, or `###`) or the end of the page.

If the page has an `## End of day` section but no `### Daily review`, add this subsection at the bottom of `## End of day`:

```md
### Daily review

```

If neither exists, append this at the bottom of the page:

```md
---

## End of day

### Daily review

```

Preserve all other page content.

## Append mode

Use append mode when the user gives a point-in-time reflection, rough notes, or “I've been working on…” content.

Append a small timestamped entry under `### Daily review`. Keep the user's voice. Do not over-format or over-summarise. Prefer this shape:

```md
**HH:mm — quick capture**

- Worked on: ...
- Tech / systems: ...
- What was hard: ...
- Interesting / learned: ...
- Follow-up: ...
```

Only include bullets that are supported by what the user said. If the user gives freeform prose, preserve it as prose under the timestamp rather than forcing every field.

Good content to capture:

- technology, tools, systems, repos, tickets, or services involved
- what digiben was doing
- what was difficult or confusing
- what was interesting or newly learned
- decisions, debugging insights, blockers, next steps
- useful CV/weekly-review language, without making it sound corporate

Do not invent details. If important context is missing, ask one short clarifying question only if needed; otherwise append what is available.

## Clean-up mode

Use clean-up mode when the user asks to clean up, consolidate, or turn the daily review into a proper review.

Read the existing `### Daily review` content and rewrite only that section into a coherent freeform review. Preserve useful details from all snippets, but remove duplication and timestamp noise.

Prefer this compact structure unless the existing notes suggest something better:

```md
Today I worked on ...

**Technology / systems:** ...

**What I did:**
- ...

**What was hard:**
- ...

**Interesting / learned:**
- ...

**Follow-ups / useful for tomorrow:**
- ...
```

Rules:

- Keep it honest and concrete.
- Keep the tone natural, like digiben's notes.
- Preserve named technologies, systems, ticket references, and people when present.
- Do not turn it into performative CV language, but make it useful for weekly review/CV mining later.
- Rewrite only the `### Daily review` body. Do not change morning goals, deep work sections, tasks, or other end-of-day sections.

## Updating Notion

After editing the Markdown locally/in memory, update the page with `ntn pages update` or the appropriate `ntn` update command available in this environment. Preserve all existing child page links and unrelated content.

Then fetch the page again to verify:

```bash
ntn pages get <page-id>
```

Check that:

- the correct daily note was updated
- `### Daily review` exists
- the new/cleaned content is in that section
- no unrelated sections were removed or duplicated

## Final response

Keep the response concise. Include:

- date used
- daily note title and URL if available
- whether you appended a capture or cleaned up the review
- any ambiguity or manual follow-up needed

Do not dump the whole note unless the user asks.
