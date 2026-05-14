# Review Tooling Config

This repo manages the review stack as a terminal-first workflow:

1. `gh-dash` for PR triage and routing
2. Hunk for PR and Git diff review
3. `gitsigns.nvim` for current-file branch comparison inside Neovim
4. local checkout, tests, and debugging when a PR needs hands-on investigation

`snacks.nvim` adds a second, editor-native GitHub flow for PR browsing and review actions. `octo.nvim` stays installed, but it is not part of the default review loop yet.

## Files Managed Here

- `gh-dash/.config/gh-dash/config.yml`
- `hunk/.config/hunk/config.toml`
- `bin/.bin/gh-pr-review`
- `bin/.bin/review-refs`
- `nvim/.config/nvim/lua/plugins/snacks.lua`
- `nvim/.config/nvim/lua/plugins/gitsigns.lua`
- `nvim/.config/nvim/lua/plugins/octo.lua`

The old `diffnav/.config/diffnav/config.yml` remains in the repo as a rollback option, but it is no longer stowed by `install.sh` and is no longer the active PR diff viewer.

## Responsibilities

### `gh-dash`

- Queue and triage open PRs
- Launch Hunk review with `D`
- Launch `lazygit` with `G`
- Keep built-in checkout on `O`
- Use Hunk as the configured diff pager

The custom `D` binding launches `gh-pr-review`, which:

- resolves the PR's base and head branches
- fetches the base branch and `refs/pull/<number>/head` locally
- opens the PR diff in Hunk via `review-refs`

### Hunk

- Default changed-code review surface
- Config lives at `hunk/.config/hunk/config.toml`
- PR reviews use `git diff --find-renames --no-color ... | hunk patch -`
- Native Git pager integration uses `hunk pager`

### `review-refs`

- Compares two refs from the current Git repository
- Pipes the generated patch into Hunk
- Used by both `gh-pr-review` and direct local branch review

Example:

```bash
review-refs main HEAD
```

### `snacks.nvim`

- Browse open and closed PRs inside Neovim
- View PR details, comments, and status checks
- Trigger review actions through the GitHub picker
- Checkout PR branches locally
- View PR diffs with syntax highlighting

This is the editor-native alternative to starting in `gh-dash`.

### `gitsigns.nvim`

- Shows signs in the current buffer against the selected git base
- Can change the sign base to another revision with `change_base`
- Can open the current file in Neovim diff mode against another revision with `diffthis`
- Can open the current file as it exists in another revision with `show`

This is the fastest path when you already know which file you want to inspect and do not need a full PR file list.

## Validation Checklist

After stowing these packages:

1. Install Hunk: `brew install modem-dev/tap/hunk`.
2. Run `./install.sh`.
3. Run `git config --global core.pager "hunk pager"`.
4. Run `gh dash`, highlight a PR, and press `D`.
5. Confirm Hunk opens with the PR diff.
6. Run `git diff` in a repo and confirm it opens through Hunk.
7. Open Neovim and run `<leader>gp` to confirm the `snacks.nvim` PR picker opens.
8. Open a tracked file, use `<leader>gb` to compare against `origin/main`, and confirm signs update.
9. Use `<leader>gv` on that file and confirm a Neovim diff split opens against the selected revision.
