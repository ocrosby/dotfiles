# ────────[ Aliases ]────────
alias ll="ls -la"
alias gti="git"

# Define common Neovim setups
for variant in personal yoda kickstart astro chad lunar lazy; do
  alias "nvim-${variant}"="NVIM_APPNAME=\"nvim-${variant}\" nvim"
done

alias yoda='NVIM_APPNAME="nvim-yoda" nvim'


# ────────[ Clone Neovim Configs If Missing ]────────
clone_if_missing() {
  local name="$1"
  local repo="$2"
  local path="$HOME/.config/nvim-$name"

  if [ ! -d "$path" ]; then
    echo "Cloning $name from $repo ..."
    git clone "$repo" "$path"
  fi
}

clone_if_missing "kickstart" "https://github.com/nvim-lua/kickstart.nvim.git"
clone_if_missing "astro"     "https://github.com/AstroNvim/AstroNvim.git"
clone_if_missing "chad"      "https://github.com/NvChad/NvChad.git"
clone_if_missing "lunar"     "https://github.com/LunarVim/LunarVim.git"
clone_if_missing "lazy"      "https://github.com/LazyVim/LazyVim.git"
clone_if_missing "personal"  "https://github.com/ocrosby/nvim.git"
clone_if_missing "yoda"      "https://github.com/jedi-knights/yoda.nvim.git"


# ────────[ Homebrew Installers ]────────
install_if_missing() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    brew install "$pkg"
  else
    echo "$cmd is already installed."
  fi
}

# Core tools
install_if_missing wget
install_if_missing rg ripgrep
install_if_missing php
install_if_missing rustup-init rust
install_if_missing julia
install_if_missing go
install_if_missing composer
install_if_missing fd

# ────────[ NVM Setup ]────────
if ! command -v nvm >/dev/null 2>&1; then
  echo "Installing nvm..."
  brew install nvm
fi

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# Use Homebrew nvm integration
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"


# ────────[ GOPATH / Go Setup ]────────
export PATH=$PATH:/usr/local/go/bin
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"


# ────────[ Java Setup ]────────
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"


# ────────[ Misc ]────────
export PATH="$HOME/bin:$PATH"
export TERM=xterm-256color

# Private file
[ -f "$HOME/.zshrc.private" ] && source "$HOME/.zshrc.private"
