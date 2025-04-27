#!/usr/bin/env python3

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

def clone_dotfiles():
    """Clone the dotfiles repository if not already present."""
    if not DOTFILES_DIR.exists():
        print(f"📦 Cloning dotfiles repo from {GIT_REPO}...")
        run(f"git clone --recurse-submodules {GIT_REPO} {DOTFILES_DIR}")

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

    clone_dotfiles()
    init_submodules()

    for src_rel, dest_rel in SYMLINKS:
        source = DOTFILES_DIR / src_rel
        destination = Path.home() / dest_rel
        symlink(source, destination)

if __name__ == "__main__":
    main()
