# PR Review Cheatsheet

## `gh-dash`

- `D`: review selected PR in `diffnav`
- `G`: open `lazygit` in the repo
- `O`: checkout selected PR

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

## `diffnav`

- `j` / `k`: move between files or nodes
- `n` / `p`: next or previous file
- `e`: toggle file tree
- `t`: search files
- `s`: toggle side-by-side or unified
- `o`: open full-file compare for the selected file
- `q`: quit

## Full-file compare

- `o` from `diffnav` opens a new `tmux` window with `nvim -d`
- quit `nvim`, close the compare window, and return to the same `diffnav` session

Direct commands:

```bash
gh-pr-review owner/repo 123
review-refs main HEAD
review-file-compare main HEAD path/to/file.ts
```

## Use This When

- `gh-dash`: triage, approval, quick comments
- `snacks.nvim`: Neovim-native GitHub search, PR details, review actions
- `diffnav`: changed-code review
- `gitsigns.nvim`: current-file branch comparison with live signs
- `nvim -d`: full-file structure or type-heavy review
- local checkout: tests, logging, runtime validation
