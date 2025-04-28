#!/usr/bin/env python3

# Note: This script assumes you have a repository in your user account named `dotfiles` if you don't create one now then attempt to run this script.

import os
import shutil
import subprocess
from pathlib import Path

# --- Configuration (edit these for your own dotfiles) ---

GIT_REPO = "git@github.com:ocrosby/dotfiles.git"  # <--- 🔥 Change this for your own dotfiles repo
DOTFILES_DIR = Path.home() / "dotfiles"

# Define source -> destination symlinks
# Each entry is (source relative to dotfiles repo, destination relative to $HOME)
SYMLINKS = [
    ("tmux/tmux.conf", ".tmux.conf"),
    ("ghostty", ".config/ghostty"),
    ("bin", "bin"),  # links ~/bin -> ~/dotfiles/bin
]

# --- Utility Functions ---

def run(command, cwd=None):
    """Run a shell command and exit on failure."""
    print(f"🔧 Running: {command}")
    result = subprocess.run(command, shell=True, cwd=cwd)
    if result.returncode != 0:
        print(f"❌ Command failed: {command}")
        exit(1)

def get_git_username():
    """Try to get the git user's name from global git config."""
    username = run("git config --global github.user", capture_output=True)
    if not username:
        # Try user.name as fallback
        username = run("git config --global user.name", capture_output=True)
        if username:
            username = username.replace(" ", "") # Remove spaces if needed

    if not username:
        print("Could not determine GitHub username automatically.")
        username = input("Please enter your GitHub username: ").strip()

    return username

def get_git_repo(username: str):
    """Construct the git repo URL based on username."""
    return f"git@github.com:{username}/dotfiles.git"

def clone_dotfiles(git_repo: str):
    """Clone the dotfiles repository if not already present."""
    if not DOTFILES_DIR.exists():
        print(f"📦 Cloning dotfiles repo from {git_repo}...")
        run(f"git clone --recurse-submodules {git_repo} {DOTFILES_DIR}")

def init_submodules():
    """Initialize git submodules."""
    print("🔄 Initializing git submodules...")
    run("git submodule update --init --recursive", cwd=DOTFILES_DIR)

def symlink(source: Path, destination: Path):
    """Safely create a symlink from source to destination."""
    if destination.exists() or destination.is_symlink():
        print(f"♻️ Removing existing {destination}")
        if destination.is_symlink() or destination.is_file():
            destination.unlink()
        elif destination.is_dir():
            shutil.rmtree(destination)

    print(f"🔗 Linking {destination} -> {source}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.symlink_to(source)

def main():
    """Main bootstrap logic."""
    print("🚀 Bootstrapping your environment...")

    username = get_git_username()
    git_repo = get_git_repo(username)

    clone_dotfiles(git_repo)
    init_submodules()

    for src_rel, dest_rel in SYMLINKS:
        source = DOTFILES_DIR / src_rel
        destination = Path.home() / dest_rel
        symlink(source, destination)

if __name__ == "__main__":
    main()
