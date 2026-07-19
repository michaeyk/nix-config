# Gaming-only setup for the gaming host. Imported from flake.nix (mike-gaming).
{pkgs, ...}: {
  imports = [
    ./sunshine.nix
  ];

  home.packages = with pkgs; [
    heroic
    protonup-qt
    protontricks
  ];
}
