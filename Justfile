# just is a command runner, Justfile is very similar to Makefile, but simpler.

############################################################################
#
#  Nix commands related to the local machine
#
# To specify a host, run `just <recipe> host=<hostname>`
# For example: `just deploy-all host=babysnacks`
# The default host is "gaming".
# 
############################################################################
host := "gaming"

default: update deploy-all

deploy-home:
  home-manager switch --flake .#{{host}}

deploy-all:
  nixos-rebuild switch --flake .#{{host}} --sudo
  home-manager switch --flake .#{{host}}

debug:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo --show-trace --verbose

update: 
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake update $(i)

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old
