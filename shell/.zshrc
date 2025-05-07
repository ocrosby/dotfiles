alias ll="ls -la"
alias gti="git"

export PATH="$HOME/bin:$PATH"

# Source private file if it exists
if [ -f "$HOME/.zshrc.private" ]; then
    source "$HOME/.zshrc.private"
fi

