# Omarchy Neovim profile

A portable snapshot of the LazyVim configuration installed on the Omarchy machine.

The live Omarchy config links `lua/plugins/theme.lua` to
`~/.config/omarchy/current/theme/neovim.lua`. This snapshot vendors the current
Tokyo Night theme instead, so it also starts on macOS and other non-Omarchy
machines. The remaining Omarchy theme hot-reload plugin is harmless outside
Omarchy; it only reacts when a `LazyReload` event is emitted.

## Install

This is an alternative to the repo's `nvim` Stow package; do not stow both.

```bash
cd ~/repos/dotfiles
stow -D nvim                  # if the existing profile is installed
[ ! -e ~/.config/nvim ] || mv ~/.config/nvim ~/.config/nvim.bak
stow -t "$HOME" nvim-omarchy
nvim
```

On first launch, `lazy.nvim` bootstraps itself and downloads the plugins pinned
in `lazy-lock.json`.

## Dependencies

Required:

- Neovim 0.11.2 or newer
- Git and internet access for plugin bootstrap

Recommended for the full LazyVim experience:

- `ripgrep`, `fd`, `fzf`, and `lazygit`
- `curl`, `tar`, a C compiler, and the `tree-sitter` CLI
- A Nerd Font in the terminal for icons
- A platform clipboard provider (`pbcopy` is built into macOS; use `wl-copy` or
  `xclip` on Linux)

Example on macOS:

```bash
brew install neovim git ripgrep fd fzf lazygit tree-sitter
```

Plugin files, Treesitter parsers, caches, sessions, and state are intentionally
not committed. Neovim recreates them below `~/.local/share/nvim`,
`~/.local/state/nvim`, and `~/.cache/nvim` (or the platform's XDG-equivalent
locations).

Optional provider packages reported by `:checkhealth` (Python `pynvim`, npm
`neovim`, Ruby `neovim`) are not needed by this profile's current plugins.
Image, Mermaid, and LaTeX rendering tools are also optional Snacks features.
