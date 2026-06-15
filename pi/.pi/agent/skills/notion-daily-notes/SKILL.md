---
name: notion-daily-notes
description: Create and maintain Benjamin's Notion weekly and daily notes using ntn. Use when the user asks to create today's note, set up a new week, inspect weekly/daily note organisation, or carry forward notes into a new daily note.
---

# Notion Daily Notes

Use this skill when digiben asks to create or inspect Notion daily/weekly notes, especially requests like “create today's notes”, “set up this week”, “carry forward yesterday”, “prep SU notes”, or “how are my weekly notes organised?”.

The goal is to follow the user's current Notion conventions rather than hard-coding a fixed structure. Discover the latest structure first, then imitate it.

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
- Existing notes use `DD/MM/YYYY`, e.g. `Daily Notes - 15/06/2026`.
- Weekly notes are Monday-based, e.g. `Weekly Notes - 15/06/2026` for the week starting Monday 15 June 2026.
- If the user says “today”, calculate both:
  - daily title: `Daily Notes - DD/MM/YYYY`
  - weekly title: `Weekly Notes - <Monday DD/MM/YYYY>`

## Discovery-first workflow

Never assume the page hierarchy is still the same. Discover it from Notion each time.

### 1. Search for existing notes

Search recent daily and weekly notes:

```bash
ntn api /v1/search -d '{"query":"Daily Notes","page_size":20}'
ntn api /v1/search -d '{"query":"Weekly Notes","page_size":20}'
```

Use the results to infer:

- the most recent prior daily note
- the current/recent weekly note pages
- the parent page that collects weekly notes
- whether today's daily note already exists
- whether this week's weekly note already exists

If search results are ambiguous, inspect candidate pages with:

```bash
ntn pages get <page-id>
```

### 2. Infer the current structure

The historical structure has been:

```text
Quarter page, e.g. Q2 2026
└── Work
    ├── Weekly Notes - DD/MM/YYYY
    │   ├── Daily Notes - DD/MM/YYYY
```

But treat this only as a hint. Prefer what the latest pages show.

To infer the container page:

1. Find the latest weekly note.
2. Look at its `parent.page_id` from search/API output.
3. Fetch the parent page.
4. Identify where weekly-note links are listed, usually under a heading such as `## Work`.

When updating a container page, preserve all existing child-page links and content.

### 3. Avoid duplicates

Before creating anything:

- Search for the exact daily title.
- Search for the exact weekly title.
- If an exact page already exists, reuse it instead of creating another.
- If a link already exists in the parent/container page, do not add a duplicate.

### 4. Create or reuse this week's weekly note

If this week's weekly note does not exist, create it under the inferred parent/container page:

```bash
ntn pages create --parent page:<parent-page-id> --json < week.md
```

`ntn pages create` may not reliably apply Markdown frontmatter as the Notion page title. If the title is empty or wrong, set it explicitly with the API:

```bash
ntn api /v1/pages/<page-id> -X PATCH -d '{"properties":{"title":{"title":[{"text":{"content":"Weekly Notes - DD/MM/YYYY"}}]}}}'
```

After the daily note exists, the weekly page should include the daily page link at the top, followed by the rest of the weekly template/content. Preserve/imitate the latest weekly note format where possible.

Default minimal weekly body if no better template is discoverable:

```md
<page url="https://app.notion.com/p/<daily-page-id-no-dashes>">Daily Notes - DD/MM/YYYY</page>
---
## Naive questions
- …
```

### 5. Create or reuse today's daily note

If today's daily note does not exist, create it as a child of this week's weekly note.

Prefer copying the structure of the most recent prior daily note, replacing filled-in content with sensible placeholders and carry-forward items. Do not hard-code the template if the user has changed the format; imitate the latest note's headings/order.

If no prior daily note is available, use this fallback template:

```md
## Morning
### Yesterday carry-over
- …
---
### Today’s deep work
1. …
### Work goals
- …
### SU notes
- …
### Life admin goals
- [ ] …
### Personal check-in
- [ ] …
---
## Deep work 1
**Goal:**
- …
**Notes:**
- …
**Results:**
- …
**Next steps:**
- …
---
## Afternoon reset
**Slack / PRs / admin:**
- …
---
## Deep work 2
**Goal:**
- …
**Notes:**
- …
**Results:**
- …
**Next steps:**
- …
---
## End of day
### Done / highlights
- …
### Not done / carried over
- …
### Open loops
- …
```

Set/fix the title explicitly via API if necessary, as with weekly notes.

### 6. Carry forward useful content

When creating a new daily note, inspect the most recent prior daily note and carry forward useful unfinished items.

Carry into `Yesterday carry-over` or the equivalent section:

- unchecked checkbox tasks (`- [ ] ...`)
- explicit `Next steps`
- `Not done / carried over`
- `Open loops`
- incomplete life-admin/personal tasks
- unfinished work goals

Carry into `SU notes` or the equivalent standup/status section:

- blockers
- project/system facts
- testing/deployment/staging/production handoff notes
- integration decisions
- named follow-ups with teammates
- unresolved work questions
- ticket references and their current state

Do not blindly copy everything. Summarise into short, actionable bullets. Preserve the user's informal tone where appropriate.

### 7. Update the parent/container page

If a new weekly note was created, add it to the parent/container page where other weekly notes are listed.

- Insert the new weekly link near the top of the existing weekly-note list.
- Usually this is under a heading such as `## Work`, but discover this from the page content.
- Preserve all other content exactly as much as possible.
- Do not duplicate the link if already present.

Important: `ntn pages update` can reject updates that would delete child pages/databases. When updating a page with child pages, keep existing child links in the Markdown using `<page url="...">Title</page>` tags unless the user explicitly asked to remove them.

### 8. Verify

After creating/updating, fetch the relevant pages to verify:

```bash
ntn pages get <weekly-page-id>
ntn pages get <daily-page-id>
```

Check that:

- titles are correct
- the daily note is under the weekly note
- the weekly note links to the daily note
- the parent/container page links to the weekly note if a new week was created
- carried-forward items are present and not duplicated excessively

### 9. Final response

Keep the response concise. Include:

- today's date used
- weekly note title and URL
- daily note title and URL
- whether content was carried forward
- any ambiguity or manual follow-up needed

Do not dump the full note content unless the user asks.
