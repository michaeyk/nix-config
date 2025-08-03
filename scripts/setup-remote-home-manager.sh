#!/usr/bin/env bash

# Script to set up home-manager on remote Ubuntu systems using flakes
# This ensures home-manager builds locally with correct Nix store paths

set -euo pipefail

echo "Setting up home-manager on remote system with flakes..."

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "Error: Nix is not installed. Please install Nix first."
    echo "Run: sh <(curl -L https://nixos.org/nix/install) --daemon"
    exit 1
fi

# Enable flakes if not already enabled
if ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "Enabling flakes..."
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Clone dotfiles if not already present
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Please clone your dotfiles repository to $DOTFILES_DIR first"
    echo "Run: git clone <YOUR_DOTFILES_REPO_URL> $DOTFILES_DIR"
    exit 1
else
    echo "Using dotfiles directory at $DOTFILES_DIR"
fi

# Navigate to dotfiles directory
cd "$DOTFILES_DIR"

# Build and activate home-manager configuration using the flake
echo "Building home-manager configuration from flake..."
echo "This will build the configuration locally with correct Nix store paths for this system."

# Use the existing home configuration from the flake
nix run home-manager/master -- switch --flake .#mike-remote

echo ""
echo "Home-manager setup complete!"
echo ""
echo "The hm-session-vars.sh file has been generated with correct paths for this system."
echo "Your shell configuration should automatically source it."
echo ""
echo "To update in the future, run from the dotfiles directory:"
echo "  cd $DOTFILES_DIR"
echo "  git pull"
echo "  nix run home-manager/master -- switch --flake .#mike-remote"