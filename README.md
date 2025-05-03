# My dotfiles

I've decided to utilize GNU Stow to help manage my `dotfiles`.  I will add additional documentation on how I set it up after I get it working.

## Requirements

Ensure you have the following installed on your system

### Git

```shell
brew install git
```

### GNU Stow

```shell
brew install stow
```

## Installation

First, check out the `dotfiles` repo in your $HOME directory using git

```shell
git clone https://github.com/ocrosby/dotfiles ~/dotfiles
cd ~/dotfiles
```

then use GNU stow to create symlinks

```shell
cd ~/dotfiles
stow */
```

Note: when using stow it seems that things work better when I invoke stow on a package by package basis.

So instead of `stow */` to setup directories I will tend to utilize.

```shell
stow shell
stow bin
stow tmux
stow config
```


## References

- [Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs)


