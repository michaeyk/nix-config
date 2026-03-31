{ pkgs, ... }:
let
  hyprDir = "/run/user/1000/hypr";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  # HDMI dummy plug connector name (IDV AOC28E850.HDR)
  dummyPlug = "HDMI-A-3";

  setHyprInstance = ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
  '';

  mkResolutionScript = name: resolution: pkgs.writeShellScript "sunshine-res-${name}" ''
    ${setHyprInstance}
    ${hyprctl} keyword monitor "${dummyPlug},${resolution},auto,1"
  '';

  restoreScript = pkgs.writeShellScript "sunshine-res-restore" ''
    ${setHyprInstance}
    ${hyprctl} keyword monitor "${dummyPlug}",disable
  '';

  # Prevent suspend while streaming (DPMS/lock still work normally)
  inhibitSuspend = pkgs.writeShellScript "sunshine-inhibit-suspend" ''
    touch /tmp/sunshine-streaming
  '';
  uninhibitSuspend = pkgs.writeShellScript "sunshine-uninhibit-suspend" ''
    rm -f /tmp/sunshine-streaming
  '';

  steamBigPicture = pkgs.writeShellScript "steam-bigpicture" ''
    ${setHyprInstance}
    export WAYLAND_DISPLAY=wayland-1
    export XDG_RUNTIME_DIR=/run/user/1000
    export HOME=/home/mike

    # Open Big Picture via steam:// URL (works whether Steam is already running or not)
    ${pkgs.libcap}/bin/capsh --caps="" --addamb="" -- -c '/run/current-system/sw/bin/flatpak run com.valvesoftware.Steam steam://open/bigpicture' &

    # Wait for Steam window, move to dummy plug, and fullscreen
    sleep 3
    for i in {1..30}; do
      if ${hyprctl} clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class == "steam")' > /dev/null 2>&1; then
        ${hyprctl} dispatch focuswindow class:steam
        ${hyprctl} dispatch movewindow "mon:${dummyPlug}"
        ${hyprctl} dispatch fullscreen 1
        ${hyprctl} dispatch focusmonitor "${dummyPlug}"
        break
      fi
      sleep 1
    done

    # Keep running so Sunshine doesn't think app exited
    sleep infinity
  '';
in
{
  xdg.configFile."sunshine/sunshine.conf".text = builtins.concatStringsSep "\n" [
    "gamepad = x360"
    "capture = wlr"
    "output_name = 1"
  ];

  xdg.configFile."sunshine/apps.json".text = builtins.toJSON {
    env = {
      PATH = "$(PATH):$(HOME)/.local/bin";
    };
    apps = [
      # Desktop profiles
      {
        name = "Desktop (4K TV)";
        image-path = "desktop.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "4ktv" "3840x2160@60"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Desktop (Fold 7)";
        image-path = "desktop.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "fold7" "modeline 557.50 2184 2232 2264 2344 1968 1971 1976 1982 +hsync -vsync"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Desktop (Steam Deck)";
        image-path = "desktop.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "steamdeck" "1280x800@60"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }

      # Steam Big Picture profiles
      {
        name = "Steam (4K TV)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "4ktv" "3840x2160@60"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Steam (Fold 7)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "fold7" "modeline 557.50 2184 2232 2264 2344 1968 1971 1976 1982 +hsync -vsync"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Steam (Steam Deck)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${mkResolutionScript "steamdeck" "1280x800@60"}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
    ];
  };
}
