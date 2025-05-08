alias ll="ls -la"
alias gti="git"
alias nvim-personal='NVIM_APPNAME="nvim-personal" nvim'
alias nvim-yoda='NVIM_APPNAME="nvim-yoda" nvim'
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias nvim-astro='NVIM_APPNAME="nvim-astro" nvim'
alias nvim-chad='NVIM_APPNAME="nvim-chad" nvim'
alias nvim-lunar='NVIM_APPNAME="nvim-lunar" nvim'
alias nvim-lazy='NVIM_APPNAME="nvim-lazy" nvim'

if [ ! -d "$HOME/.config/nvim-kickstart" ]; then
    echo "Cloning kickstart.nvim repository ..."
    git clone https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim-kickstart"
fi

if [ ! -d "$HOME/.config/nvim-astro" ]; then
    echo "Cloning the AstroNvim repository ..."
    git clone https://github.com/AstroNvim/AstroNvim.git "$HOME/.config/nvim-astro"
fi

if [ ! -d "$HOME/.config/nvim-chad" ]; then
    echo "Cloning the NvChad repository ..."
    git clone https://github.com/NvChad/NvChad.git "$HOME/.config/nvim-chad"
fi

if [ ! -d "$HOME/.config/nvim-lunar" ]; then
    echo "Cloning the LunarVim repository ..."
    git clone https://github.com/LunarVim/LunarVim.git "$HOME/.config/nvim-lunar"
fi

if [ ! -d "$HOME/.config/nvim-lazy" ]; then
    echo "Cloning the LazyVim repository ..."
    git clone https://github.com/LazyVim/LazyVim.git "$HOME/.config/nvim-lazy"
fi

if [ ! -d "$HOME/.config/nvim-personal" ]; then
    echo "Cloning my personal Neovim configuration ..."
    git clone https://github.com/ocrosby/nvim.git "$HOME/.config/nvim-personal"
fi

if [ ! -d "$HOME/.config/nvim-yoda" ]; then
    echo "Cloning my Yoda distribution ..."
    git clone https://github.com/jedi-knights/yoda.git "$HOME/.config/nvim-yoda"
fi


export PATH="$HOME/bin:$PATH"

# Source private file if it exists
if [ -f "$HOME/.zshrc.private" ]; then
    source "$HOME/.zshrc.private"
fi

