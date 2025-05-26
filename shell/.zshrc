# ────────[ Aliases ]────────
alias ll="ls -la"
alias gti="git"

# Define common Neovim setups
for variant in personal yoda kickstart astro chad lunar lazy; do
  alias "nvim-${variant}"="NVIM_APPNAME=\"nvim-${variant}\" nvim"
done
alias yoda='NVIM_APPNAME="nvim-yoda" nvim'

# ────────[ Environment Variables ]────────
export GOPATH="$HOME/go"
export NVM_DIR="$HOME/.nvm"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export TERM=xterm-256color
export DOTFILES_VERBOSE=false

# Consolidated PATH
export PATH="$HOME/bin:$GOPATH/bin:/usr/local/go/bin:/opt/homebrew/opt/openjdk/bin:$PATH"

# ────────[ Load Setup Logic ]────────
[ -f "$HOME/.zsh.setup" ] && source "$HOME/.zsh.setup"

# ────────[ Load Private Secrets/Overrides ]────────
[ -f "$HOME/.zshrc.private" ] && source "$HOME/.zshrc.private"
