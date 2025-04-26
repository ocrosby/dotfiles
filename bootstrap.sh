#!/usr/bin/env bash

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Bootstrapping your environment..."

# --- Step 1: Clone dotfiles if needed ---
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "📦 Cloning dotfiles repo..."
  git clone --recurse-submodules git@github.com:ocrosby/dotfiles.git "$DOTFILES_DIR"
fi

# --- Step 2: Initialize submodules ---
echo "🔄 Initializing git submodules..."
cd "$DOTFILES_DIR" || exit 1
git submodule update --init --recursive

# --- Step 3: Symlink configurations ---

# Symlink ~/.tmux.conf
if [ ! -L "$HOME/.tmux.conf" ]; then
  echo "🔗 Linking tmux.conf..."
  ln -sfn "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# Symlink ~/.config/ghostty
if [ ! -L "$HOME/.config/ghostty" ]; then
  echo "🔗 Linking Ghostty config..."
  mkdir -p "$HOME/.config"
  ln -sfn "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"
fi

# (Add more symlinks here if you want — e.g., Neovim, Zsh, etc.)

# --- Step 4: Install TPM plugins (optional) ---
if command -v tmux &> /dev/null; then
  echo "🔧 Installing TPM plugins..."
  tmux start-server
  tmux new-session -d
  "$DOTFILES_DIR/tmux/plugins/tpm/bin/install_plugins"
  tmux kill-server
fi

echo "✅ Bootstrap complete!"

