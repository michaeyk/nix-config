{ pkgs, ... }:
let
  hyprDir = "/run/user/1000/hypr";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  monitor = "desc:Samsung Electric Company Odyssey G95SC";

  sunshineResolutionScript = pkgs.writeShellScript "sunshine-resolution" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
    ${hyprctl} keyword monitor "${monitor}",2560x1440@120,0x0,1
  '';

  sunshineResolutionRestore = pkgs.writeShellScript "sunshine-resolution-restore" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
    ${hyprctl} keyword monitor "${monitor}",5120x1440@240,0x0,1
  '';

  steamBigPicture = pkgs.writeShellScript "steam-bigpicture" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
    export WAYLAND_DISPLAY=wayland-1
    export XDG_RUNTIME_DIR=/run/user/1000
    export HOME=/home/mike

    # Launch Steam Flatpak with dropped capabilities (fixes bwrap error with Sunshine's capSysAdmin)
    ${pkgs.libcap}/bin/capsh --caps="" --addamb="" -- -c '/run/current-system/sw/bin/flatpak run com.valvesoftware.Steam -bigpicture -steamos' &

    # Wait for Steam window to appear and make it fullscreen
    for i in {1..30}; do
      if ${hyprctl} clients | grep -q "steam"; then
        sleep 1
        ${hyprctl} dispatch focuswindow class:steam
        ${hyprctl} dispatch fullscreen 1
        break
      fi
      sleep 0.5
    done

    # Keep running so Sunshine doesn't think app exited
    sleep infinity
  '';
in
{
  xdg.configFile."sunshine/sunshine.conf".text = ''
    gamepad = auto
  '';

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
