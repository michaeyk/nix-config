# Remote Ubuntu System Setup with Home Manager

This guide explains how to set up your dotfiles and home-manager configuration on remote Ubuntu systems.

## Problem

When using home-manager across different machines, the generated `hm-session-vars.sh` file contains hardcoded Nix store paths that are specific to the build machine. This causes sourcing to fail on remote systems where the paths don't exist.

## Solution

Build home-manager configurations locally on each machine using the flake, which ensures all Nix store paths are correct for that specific system.

## Setup Instructions

### 1. Install Nix on the Remote System

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 2. Clone Your Dotfiles Repository

```bash
git clone <YOUR_DOTFILES_REPO_URL> ~/.dotfiles
```

### 3. Run the Setup Script

```bash
~/.dotfiles/scripts/setup-remote-home-manager.sh
```

This script will:
- Enable flakes in your Nix configuration
- Build your home-manager configuration from the flake
- Generate `hm-session-vars.sh` with correct paths for the remote system
- Activate the configuration

### 4. Restart Your Shell

Log out and back in, or source your shell configuration:

```bash
source ~/.zshrc  # or ~/.bashrc
```

## Updating Configuration

To update your configuration after making changes:

```bash
cd ~/.dotfiles
git pull
nix run home-manager/master -- switch --flake .#mike
```

## How It Works

1. The flake defines your home-manager configuration
2. Running `home-manager switch` on each machine builds the configuration locally
3. This generates `hm-session-vars.sh` with paths specific to that machine's Nix store
4. Your shell configuration automatically sources this file with the correct paths

## Troubleshooting

If you encounter issues:

1. **Nix command not found**: Ensure you've restarted your shell after installing Nix
2. **Flakes not enabled**: Check `~/.config/nix/nix.conf` contains `experimental-features = nix-command flakes`
3. **Build failures**: Ensure all dependencies in your configuration are available for the target platform
