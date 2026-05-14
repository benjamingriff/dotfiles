# PR Review Usage Guide

This workflow is optimized for terminal-first PR review with `gh-dash` and Hunk, while still supporting Neovim-native GitHub actions through `snacks.nvim` and file-level branch comparison through `gitsigns.nvim`.

1. skim the PR in `gh-dash`
2. review the changed code in Hunk
3. checkout and run code only when the diff is not enough

## PR Triage

Start in `gh dash`.

Use this layer to:

- see what needs review
- skim the PR title, author, status, and description
- approve simple PRs
- leave quick comments
- decide whether the PR needs deeper review

Use these keys:

- `D` to start code review in Hunk
- `G` to open `lazygit` in the repo
- `O` to checkout the PR locally

## Code Review In Hunk

Once a PR looks non-trivial, press `D` in `gh-dash`.

The flow is:

```text
gh-dash -> gh-pr-review -> review-refs -> hunk patch -
```

`gh-pr-review` fetches the PR base and head refs locally, then `review-refs` pipes a no-colour Git diff into Hunk.

You can use the same flow manually from any repo:

```bash
review-refs main HEAD
```

For local working-tree changes, use Hunk directly:

```bash
hunk diff
hunk diff --watch
```

For commits:

```bash
hunk show
hunk show HEAD~1
```

## Native Git Diff Viewer

Hunk is intended to be the global Git pager:

```bash
git config --global core.pager "hunk pager"
```

That makes these open in Hunk:

```bash
git diff
git show
git log -p
```

## Neovim Paths

If you want to stay inside Neovim, use the `snacks.nvim` GitHub picker:

- `<leader>gp` for open PRs
- `<leader>gP` for all PRs
- `<leader>gi` for open issues
- `<leader>gI` for all issues

From a PR picker entry, press `<CR>` to open the action menu. That lets you view PR details, checkout the PR locally, review, comment, approve, request changes, or open the PR in the browser.

Once a branch is checked out locally, `gitsigns.nvim` gives you fast file-level comparison tools:

- `<leader>gb` to change the sign base to another revision
- `<leader>gv` to diff the current file against a revision in side-by-side Neovim diff mode
- `<leader>gV` to diff the current file against the index
- `<leader>gS` to open the current file as it exists in another revision

## Running Code On The PR

If the diff still leaves uncertainty, move to local execution.

From `gh-dash`:

- press `O` to checkout the PR
- or open `lazygit` with `G` and work from there

Then run the relevant tests, inspect runtime behavior, and verify assumptions the diff could not prove.

## Default Decision Rule

Use this path by default:

1. `gh-dash` for triage
2. Hunk for code review
3. checkout and run code only when the diff leaves real uncertainty

Use the `snacks.nvim` path when you want GitHub search, PR metadata, comments, checkout, and review actions without leaving Neovim.

Use the `gitsigns.nvim` path when the question is narrower: "how does this one file differ from another branch, commit, or the index?"
