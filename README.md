# Dotfiles!

This repository contains a managed collection of dotfiles and configuration files for macOS, organized with [GNU Stow](https://www.gnu.org/software/stow/).
The goal is to keep everything modular, reproducible, and easy to set up on a new machine.

---

## 📂 Repository Structure

Each top-level directory in this repo is a **stow package**.
Inside each package, the directory structure mirrors the layout of `$HOME`.

For example:


dotfiles/ zshrc/        → contains .zshrc nvim/         → contains .config/nvim/ ghostty/      → contains .config/ghostty/ sketchybar/   → contains .config/sketchybar/ skhd/         → contains .skhdrc
yabai/        → contains .config/yabai/ yazi/         → contains .config/yazi/


This means:
- Running `stow zshrc` will symlink `.zshrc` into `~/.zshrc`.
- Running `stow nvim` will symlink `.config/nvim` into `~/.config/nvim`.

---

## ⚡ Installation

Clone the repo into `~/repos/dotfiles` (or your preferred location):

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
```

Then run the install script to stow all packages:

./install.sh

This will symlink everything into the correct locations under $HOME.

─────────────────────────────────────────

## 🔧 Managing Packages

• Stow a package
stow -t ~ nvim
This creates symlinks from dotfiles/nvim/.config/nvim/ into ~/.config/nvim/.
• Unstow a package
stow -D nvim
This removes the symlinks created by stow.
• Restow (update symlinks)
stow -R nvim


─────────────────────────────────────────

## 👀 Checking Existing Symlinks

Stow doesn’t keep a registry of what’s installed — it just creates symlinks. To see what’s currently linked:

ls -l ~ | grep '\->'
ls -l ~/.config | grep '\->'

This shows which files and directories are symlinked and where they point.

─────────────────────────────────────────

## 📜 install.sh

The included script automates stowing all packages:

#!/usr/bin/env bash
# install.sh - symlink all dotfiles with stow

DOTFILES_DIR="$HOME/repos/dotfiles"
cd "$DOTFILES_DIR" || exit 1

PACKAGES=(
  zshrc
  nvim
  ghostty
  sketchybar
  skhd
  yabai
  yazi
)

for pkg in "${PACKAGES[@]}"; do
  echo "Stowing $pkg..."
  stow -t "$HOME" "$pkg"
done

Run it once after cloning to set up your environment.

─────────────────────────────────────────

## 🛠 Best Practices

• Keep one package per app/tool for modularity.
• Mirror the exact structure of $HOME inside each package.
• Use stow -D to cleanly remove symlinks.
• Use stow -R to refresh symlinks after making changes.

─────────────────────────────────────────
