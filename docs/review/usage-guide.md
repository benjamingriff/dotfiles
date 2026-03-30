# PR Review Usage Guide

This workflow is optimized for terminal-first PR review with fast escalation, while also supporting a Neovim-native GitHub path through `snacks.nvim` and file-level branch comparison through `gitsigns.nvim`:

1. skim the PR in `gh-dash`
2. review the changed code in `diffnav`
3. jump to full-file compare in `nvim -d` when structure matters
4. checkout and run code only when the diff is not enough

## The Three Modes

### 1. PR Triage

Start in `gh dash`.

Use this layer to:

- see what needs review
- skim the PR title, author, status, and description
- approve simple PRs
- leave quick comments
- decide whether the PR needs deeper review

Use these keys:

- `D` to start code review in `diffnav`
- `G` to open `lazygit` in the repo
- `O` to checkout the PR locally

If you want to stay inside Neovim instead, use the `snacks.nvim` GitHub picker:

- `<leader>gp` for open PRs
- `<leader>gP` for all PRs
- `<leader>gi` for open issues
- `<leader>gI` for all issues

From a PR picker entry, press `<CR>` to open the action menu. That lets you:

- open the PR details in a buffer
- view the PR diff with syntax highlighting
- checkout the PR locally
- review, comment, approve, or request changes
- open the PR in the browser when needed

Once a branch is checked out locally, `gitsigns.nvim` gives you fast file-level comparison tools:

- `<leader>gb` to change the sign base to another revision
- `<leader>gv` to diff the current file against a revision in side-by-side Neovim diff mode
- `<leader>gV` to diff the current file against the index
- `<leader>gS` to open the current file as it exists in another revision

### 2. Side-by-Side Code Review

Once a PR looks non-trivial, press `D`.

This opens the PR in `diffnav` with:

- side-by-side diff view
- a file tree for moving across changed files
- low-noise UI so code and file structure stay readable

This is the default review mode.

Use it to answer:

- what changed
- where the changes are clustered
- how broad the change is
- whether the implementation shape looks sane before you run anything

If you start from `snacks.nvim`, use its PR picker and choose `View diff` from the action menu. That keeps the whole review inside Neovim, but it is still a diff view rather than a true full-file side-by-side comparison.

## Reviewing Types And Structural Changes

Type-heavy changes are where the workflow intentionally escalates from `diffnav` to `nvim -d`.

Start in `diffnav` and inspect the changed hunks. If the change touches:

- interfaces
- TypeScript types
- schemas
- DTOs
- config shapes
- constructor signatures
- public function signatures

then hunk context is often not enough.

Press `o` on the file to open a full-file side-by-side compare in a new `tmux` window.

That compare is useful for:

- seeing unchanged declarations around the modified type
- checking imports and exports
- comparing ordering and grouping of fields
- confirming whether type changes ripple into nearby helpers or adapters
- understanding whether the file shape still makes sense as a whole

When done:

- quit `nvim`
- close the compare window
- continue in the original `diffnav` session

For single-file investigation after a PR branch is checked out, `gitsigns.nvim` is faster than going back through `diffnav`. It is especially useful when you want to compare the file you are currently editing against `origin/main`, a release branch, or a specific commit while keeping Git signs visible in the working buffer.

## 3. Running Code On The PR

If the diff still leaves uncertainty, move to local execution.

From `gh-dash`:

- press `O` to checkout the PR
- or open `lazygit` with `G` and work from there

Then:

- run the relevant tests
- add temporary logging
- inspect runtime behavior
- verify assumptions the diff could not prove

Use this mode when:

- logic depends on runtime state
- a refactor changed control flow
- the PR modifies data transformation or persistence behavior
- the types look right but behavior still needs proving

If you started in `snacks.nvim`, the handoff is the same once the branch is checked out locally:

- run tests from the terminal
- inspect files in Neovim
- use `review-file-compare` or `diffnav` when you want branch-vs-branch comparison outside the PR UI

## Local Branch And Agent Review

You can use the same deep-review flow for local work, not only GitHub PRs.

From a repo:

```bash
review-refs main HEAD
```

That opens a side-by-side diff review between `main` and `HEAD`. Inside `diffnav`, `o` still opens full-file compare in `nvim -d`.

You can also compare one file directly:

```bash
review-file-compare main HEAD path/to/file.ts
```

Or stay inside Neovim on the current file:

- `<leader>gb` then enter `origin/main` to update signs against that branch
- `<leader>gv` then enter `origin/main` to open a side-by-side diff split for the file
- use `]h` and `[h` to move between hunks in the working buffer

## Default Decision Rule

Use this escalation path by default:

1. `gh-dash` for triage
2. `diffnav` for code review
3. `nvim -d` for full-file comparison
4. checkout and run code only when the code review still leaves real uncertainty

Use the `snacks.nvim` path when you want GitHub search, PR metadata, comments, checkout, and review actions without leaving Neovim.

Use the `gitsigns.nvim` path when the question is narrower: "how does this one file differ from another branch, commit, or the index?"
