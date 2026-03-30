#!/usr/bin/env bash
# install.sh - symlink all dotfiles with stow

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

if ! command -v stow &>/dev/null; then
  echo "Error: stow is not installed. Install it with: brew install stow"
  exit 1
fi

PACKAGES=(
  bin
  diffnav
  ghostty
  gh-dash
  goose
  nvim
  opencode
  sketchybar
  skhd
  starship
  tmux
  yabai
  yazi
  zshrc
)

failed=0

for pkg in "${PACKAGES[@]}"; do
  if stow -R -t "$HOME" "$pkg" 2>&1; then
    echo "✓ $pkg"
  else
    echo "✗ $pkg failed"
    failed=1
  fi
done

if [ "$failed" -eq 0 ]; then
  echo ""
  echo "All packages stowed successfully."
else
  echo ""
  echo "Some packages failed. Check the output above."
  exit 1
fi
