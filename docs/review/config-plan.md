# Review Tooling Config

This repo manages the review stack as a terminal-first workflow:

1. `gh-dash` for PR triage and routing
2. `diffnav` for side-by-side diff review
3. `nvim -d` in a new `tmux` window for full-file comparison
4. `gitsigns.nvim` for current-file branch comparison inside Neovim
5. local checkout, tests, and debugging when a PR needs hands-on investigation

`snacks.nvim` adds a second, editor-native GitHub flow for PR browsing and review actions. `octo.nvim` stays installed, but it is not part of the default review loop yet.

## Files Managed Here

- `gh-dash/.config/gh-dash/config.yml`
- `diffnav/.config/diffnav/config.yml`
- `bin/.bin/gh-pr-review`
- `bin/.bin/review-refs`
- `bin/.bin/review-open-file`
- `bin/.bin/review-file-compare`
- `nvim/.config/nvim/lua/plugins/snacks.lua`
- `nvim/.config/nvim/lua/plugins/gitsigns.lua`
- `nvim/.config/nvim/lua/plugins/octo.lua`

## Responsibilities

### `gh-dash`

- Queue and triage open PRs
- Launch deep review with `D`
- Launch `lazygit` with `G`
- Keep built-in checkout on `O`

### `snacks.nvim`

- Browse open and closed PRs inside Neovim
- View PR details, comments, and status checks
- Trigger review actions through the GitHub picker
- Checkout PR branches locally
- View PR diffs with syntax highlighting

This is the editor-native alternative to starting in `gh-dash`.

The custom `D` binding launches `gh-pr-review`, which:

- resolves the PR's base and head branches
- fetches the base branch and `refs/pull/<number>/head` locally
- opens the PR diff in `diffnav`
- sets the review context so `diffnav` can hand a selected file to `nvim -d`

### `diffnav`

- Default deep review surface
- Starts in side-by-side mode
- Hides header/footer to reduce noise
- Keeps the file tree visible
- Uses the built-in `o` key to open the selected file in `$EDITOR`

In this workflow, `$EDITOR` is temporarily set to `review-open-file`.

### `review-open-file`

- Runs when you press `o` inside `diffnav`
- Opens a new `tmux` window if available
- Launches `review-file-compare` for the selected file

Because `diffnav` stays in the original pane/window, returning is just:

- quit `nvim`
- close the compare window
- resume review in the same `diffnav` session

### `review-file-compare`

- materializes the selected file from both refs into a temp directory
- opens them with `nvim -d -R`
- gives you a true full-file side-by-side comparison with Vim diff highlighting

This is the escape hatch for type-heavy changes where hunk context is not enough.

`snacks.nvim` can also show PR diffs, but `nvim -d` remains the only true full-file side-by-side compare path in this setup.

### `gitsigns.nvim`

- Shows signs in the current buffer against the selected git base
- Can change the sign base to another revision with `change_base`
- Can open the current file in Neovim diff mode against another revision with `diffthis`
- Can open the current file as it exists in another revision with `show`

This is the fastest path when you already know which file you want to inspect and do not need a full PR file list.

## Validation Checklist

After stowing these packages:

1. Run `gh dash`, highlight a PR, and press `D`.
2. Confirm `diffnav` opens in side-by-side mode with the simplified UI.
3. Inside `diffnav`, press `o` on a changed file.
4. Confirm a new `tmux` window opens with `nvim -d`.
5. Quit that window and confirm the original `diffnav` session is still where you left it.
6. Open Neovim and run `<leader>gp` to confirm the `snacks.nvim` PR picker opens.
7. Open a PR from `snacks.nvim`, inspect the action menu, and confirm `View diff` and `Checkout` work.
8. Open a tracked file, use `<leader>gb` to compare against `origin/main`, and confirm signs update.
9. Use `<leader>gv` on that file and confirm a Neovim diff split opens against the selected revision.
10. Verify `review-file-compare main HEAD path/to/file` also works directly in a local repo.
