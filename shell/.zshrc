# ────────[ Functions ]────────
twc() { cd ~/src/github/TheWeatherCompany; }
# testing() { cd ~/src/github/TheWeatherCompany/qa/testing; }
# core() { cd ~/src/github/TheWeatherCompany/qa/core; }
# tools() { cd ~/src/github/TheWeatherCompany/qa/core/sun-qa-python-tools; }
# market() { cd ~/src/github/TheWeatherCompany/sun-claude-marketplace; }
# ocrosby()  { cd ~/src/github/ocrosby; }
# yodad() { cd ~/src/github/jedi-knights/yoda.nvim; }
# snvimd() { cd ~/src/github/TheWeatherCompany/sun-neovim; }

# ────────[ Aliases ]────────
eval "$(zoxide init zsh)"
alias ll="ls -la"
# alias gti="git"

# Define common Neovim setups
for variant in personal yoda kickstart astro chad lunar lazy; do
  alias "nvim-${variant}"="NVIM_APPNAME=\"nvim-${variant}\" nvim"
done
unset variant
alias yoda='NVIM_APPNAME="nvim-yoda" nvim'
alias snvim='NVIM_APPNAME="sun-neovim" nvim'

# ────────[ Completion ]────────
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi
autoload -Uz compinit && compinit -C

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

# ────────[ Dotfiles Utility ]────────
alias setup-dev-env="source ~/.zsh.setup"

# ────────[ Load Private Secrets/Overrides ]────────
[ -f "$HOME/.zshrc.private" ] && source "$HOME/.zshrc.private"

unset VIMRUNTIME

