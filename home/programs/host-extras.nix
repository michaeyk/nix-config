# Extra desktop apps for the "full" hosts (gaming + babysnacks), kept out of the
# default home.nix package set. Imported per-host from flake.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    zulu21
    jellyfin-media-player
    jellyfin-mpv-shim
    # lutris
    tradingview
    rustdesk-flutter
    shotcut
    kdenlive-patched-dbus
    kdenlive-mcp-dbus
  ];

  # Background daemon that lets the Jellyfin web/mobile app "cast" playback to
  # the local mpv, the way Chromecast works. Needs a one-time `jellyfin-mpv-shim
  # add` to pair credentials before it'll do anything.
  systemd.user.services.jellyfin-mpv-shim = {
    Unit = {
      Description = "Jellyfin MPV Shim";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim --no-gui";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  home.file."kdenlive/.mcp.json" = {
    force = true;
    text = ''
      {
        "mcpServers": {
          "kdenlive": {
            "type": "stdio",
            "command": "${pkgs.kdenlive-mcp-dbus}/bin/kdenlive-mcp-dbus",
            "args": [],
            "env": {}
          }
        }
      }
    '';
  };
}
