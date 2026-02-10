{ pkgs, ... }:
let
  hyprDir = "/run/user/1000/hypr";

  sunshineResolutionScript = pkgs.writeShellScript "sunshine-resolution" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)

    if [ -n "$SUNSHINE_CLIENT_WIDTH" ] && [ -n "$SUNSHINE_CLIENT_HEIGHT" ]; then
      ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@60,0x0,1
    fi
  '';

  sunshineResolutionRestore = pkgs.writeShellScript "sunshine-resolution-restore" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
    ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,3840x1080@120,0x0,1
  '';

  steamBigPicture = pkgs.writeShellScript "steam-bigpicture" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
    export WAYLAND_DISPLAY=wayland-1
    export XDG_RUNTIME_DIR=/run/user/1000
    export HOME=/home/mike

    # Change resolution to match client
    if [ -n "$SUNSHINE_CLIENT_WIDTH" ] && [ -n "$SUNSHINE_CLIENT_HEIGHT" ]; then
      ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@60,0x0,1
      sleep 1
    fi

    # Launch Steam with dropped capabilities (fixes bwrap error with Sunshine's capSysAdmin)
    ${pkgs.libcap}/bin/capsh --caps="" --addamb="" -- -c '/run/current-system/sw/bin/steam -bigpicture -steamos' &

    # Wait for Steam window to appear and make it fullscreen
    for i in {1..30}; do
      if ${pkgs.hyprland}/bin/hyprctl clients | grep -q "steam"; then
        sleep 1
        ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow class:steam
        ${pkgs.hyprland}/bin/hyprctl dispatch fullscreen 1
        break
      fi
      sleep 0.5
    done

    # Keep running so Sunshine doesn't think app exited
    sleep infinity
  '';
in
{
  xdg.configFile."sunshine/apps.json".text = builtins.toJSON {
    env = {
      PATH = "$(PATH):$(HOME)/.local/bin";
    };
    apps = [
      {
        name = "Desktop";
        image-path = "desktop.png";
      }
      {
        name = "Steam Big Picture";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        detached = ["steam"];
        prep-cmd = [
          {
            "do" = "${sunshineResolutionScript}";
            undo = "${sunshineResolutionRestore}";
          }
        ];
      }
    ];
  };
}
