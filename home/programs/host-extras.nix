# Extra desktop apps for the "full" hosts (gaming + babysnacks), kept out of the
# default home.nix package set. Imported per-host from flake.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    zulu21
    jellyfin-media-player
    # lutris
    tradingview
    rustdesk-flutter
    shotcut
  ];
}
