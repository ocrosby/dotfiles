#!/usr/bin/env python3

import os
import shutil
import subprocess
from pathlib import Path

# --- Configuration ---
HOME = Path.home()
DOTFILES_DIR = HOME / "dotfiles"

# --- Define your symlinks here ---
# Each tuple is: (source relative to dotfiles, destination relative to $HOME)
SYMLINKS = [
    ("tmux/tmux.conf", ".tmux.conf"),
    ("ghostty", ".config/ghostty"),
    ("bin", "bin"),
]

def run(command, cwd=None):
    """Run a shell command and exit on failure."""
    print(f"🔧 Running: {command}")
    result = subprocess.run(command, shell=True, cwd=cwd)
    if result.returncode != 0:
        print(f"❌ Command failed: {command}")
        exit(1)

def clone_dotfiles():
    if not DOTFILES_DIR.exists():
        print("📦 Cloning dotfiles repo...")
        run(f"git clone --recurse-submodules git@github.com:ocrosby/dotfiles.git {DOTFILES_DIR}")

def init_submodules():
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
    print("🚀 Bootstrapping your environment...")

    clone_dotfiles()
    init_submodules()

    for src_rel, dest_rel in SYMLINKS:
        source = DOTFILES_DIR / src_rel
        destination = HOME / dest_rel
        symlink(source, destination)

if __name__ == "__main__":
    main()

