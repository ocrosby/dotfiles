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

Note: It is important that you include the `/` after the `*` character in the stow command due how stow works.


## References

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs)


