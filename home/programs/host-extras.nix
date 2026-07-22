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
    kdenlive-patched-dbus
    kdenlive-mcp-dbus
  ];

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
