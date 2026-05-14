# PR Review Cheatsheet

## `gh-dash`

- `D`: review selected PR in Hunk
- `G`: open `lazygit` in the repo
- `O`: checkout selected PR

## Hunk

- Used for PR diffs launched from `gh-dash`
- Used as the Git pager via `hunk pager`
- Local review command: `review-refs main HEAD`
- Working tree review: `hunk diff`
- Latest commit review: `hunk show`

## `snacks.nvim`

- `<leader>gp`: open PR picker
- `<leader>gP`: open all PRs
- `<leader>gi`: open issue picker
- `<leader>gI`: open all issues
- `<CR>` on a PR: open the action menu
- `View diff`: inspect the PR diff inside Neovim
- `Checkout`: fetch and checkout the PR branch locally
- `Review`: approve, comment, or request changes from Neovim

## `gitsigns.nvim`

- `]h` / `[h`: move between hunks in the current file
- `<leader>hp`: preview the current hunk
- `<leader>hi`: preview the current hunk inline
- `<leader>gb`: change the sign base to another branch or revision
- `<leader>gv`: side-by-side diff the current file against another revision
- `<leader>gV`: side-by-side diff the current file against the index
- `<leader>gS`: open the current file from another revision
- `<leader>tb`: toggle current-line blame
- `<leader>tw`: toggle word diff

## Direct commands

```bash
gh-pr-review owner/repo 123
review-refs main HEAD
hunk diff
hunk show HEAD
```

## Use This When

- `gh-dash`: triage, approval, quick comments
- Hunk: changed-code review
- `snacks.nvim`: Neovim-native GitHub search, PR details, review actions
- `gitsigns.nvim`: current-file branch comparison with live signs
- local checkout: tests, logging, runtime validation
