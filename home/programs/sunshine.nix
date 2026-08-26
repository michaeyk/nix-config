{ pkgs, ... }:
let
  hyprDir = "/run/user/1000/hypr";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  # HDMI dummy plug — match by description, since the connector name (HDMI-A-1
  # vs HDMI-A-3) is not stable across reboots. Kept always-enabled and parked
  # off to the side (see home/programs/hypr/default.nix); we only ever change
  # its mode here, never disable/re-enable it — Hyprland has a known bug
  # where disabling a monitor and re-enabling it can leave it stuck dark and
  # require a full session restart to recover.
  dummyPlugDesc = "IDV AOC28E850.HDR";
  dummyPlug = "desc:${dummyPlugDesc}";
  # sunshine.conf's output_name (below) needs the raw connector name, unlike
  # Hyprland's own "desc:" rules — Sunshine's real per-session capture path
  # (as opposed to its encoder-capability probe) matches output_name against
  # the exact connector name string, not a numeric index or description. If
  # this ever mismatches after a reboot/driver update, check the current
  # name via `hyprctl monitors all` and update this.
  dummyPlugConnector = "HDMI-A-3";
  primaryMonitor = "desc:Samsung Electric Company Odyssey G95SC";
  parkedMode = "640x480@59.94";
  parkedPosition = "6000x0";

  setHyprInstance = ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 ${hyprDir}/ | head -1)
  '';

  # Dynamic Hyprland config/dispatcher changes must go through "hyprctl eval"
  # under the Lua config (configType = "lua" in hypr/default.nix) — the
  # classic "hyprctl keyword ..." and "hyprctl dispatch <name> <args>" forms
  # both silently no-op there.
  setDummyPlugMode = mode: ''
    ${hyprctl} eval 'hl.monitor({ output = "${dummyPlug}", mode = "${mode}", position = "${parkedPosition}", scale = 1 })'
  '';

  focusMonitor = output: ''
    ${hyprctl} eval 'hl.dispatch(hl.dsp.focus({ monitor = "${output}" }))'
  '';

  moveCursor = x: y: ''
    ${hyprctl} eval 'hl.dispatch(hl.dsp.cursor.move({ x = ${toString x}, y = ${toString y} }))'
  '';

  # Polls the dummy plug's reported size until it matches (width, height), up
  # to 5s, so callers don't proceed before Hyprland has actually applied the
  # mode change and Sunshine's wlr capture enumerates the old resolution.
  waitForSize = width: height: ''
    for i in $(seq 1 50); do
      if ${hyprctl} -j monitors all | ${pkgs.jq}/bin/jq -e \
          --arg desc "${dummyPlugDesc}" --argjson w ${toString width} --argjson h ${toString height} \
          '.[] | select(.description | startswith($desc)) | .width == $w and .height == $h' \
          > /dev/null 2>&1; then
        break
      fi
      sleep 0.1
    done
  '';

  # Sunshine's encoder-capability probe honors output_name, but the real
  # per-client capture instead follows compositor focus — it always grabs
  # whichever monitor is currently focused, regardless of output_name. So
  # the dummy plug must be focused *before* the client connects.
  waitForFocus = ''
    for i in $(seq 1 50); do
      if ${hyprctl} -j monitors all | ${pkgs.jq}/bin/jq -e \
          --arg desc "${dummyPlugDesc}" \
          '.[] | select(.description | startswith($desc)) | .focused' \
          > /dev/null 2>&1; then
        break
      fi
      sleep 0.1
    done
  '';

  mkResolutionScript = name: mode: width: height: pkgs.writeShellScript "sunshine-res-${name}" ''
    ${setHyprInstance}
    ${setDummyPlugMode mode}
    ${waitForSize width height}
    ${focusMonitor dummyPlug}
    # input:follow_mouse is on, so focus keeps snapping back to whatever's
    # under the physical cursor — which is always the real monitor, since
    # nothing ever moves the pointer onto the parked dummy plug otherwise.
    # Relocate it there too so focus actually sticks.
    ${moveCursor 6010 10}
    ${waitForFocus}
  '';

  restoreScript = pkgs.writeShellScript "sunshine-res-restore" ''
    ${setHyprInstance}
    ${setDummyPlugMode parkedMode}
    ${focusMonitor primaryMonitor}
    ${moveCursor 100 100}
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
    steam steam://open/bigpicture &

    # Wait for Steam window, move it to the dummy plug
    sleep 3
    for i in {1..30}; do
      if ${hyprctl} clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class == "steam")' > /dev/null 2>&1; then
        ${hyprctl} eval 'hl.dispatch(hl.dsp.focus({ window = "class:steam" }))'
        ${hyprctl} eval 'hl.dispatch(hl.dsp.window.move({ monitor = "${dummyPlug}" }))'
        ${focusMonitor dummyPlug}
        break
      fi
      sleep 1
    done

    # Launching a game from Big Picture opens it as a separate window
    # (e.g. steam_app_<id>) sometime later and asynchronously. Keep watching
    # the dummy plug and fullscreen each window there the *first* time we
    # see it, then leave it alone — Steam's own window may legitimately
    # need to drop out of fullscreen during the handoff to the game, and
    # re-forcing it on every poll would fight that transition instead of
    # letting it happen.
    #
    # Bounded to 24 hours, not "while true": Sunshine only runs this app's
    # Undo Cmd (which clears /tmp/sunshine-streaming, restoring normal
    # hypridle lock/suspend, and resets the dummy plug's resolution/focus)
    # once this script's process exits — not when the client disconnects,
    # and not when the game itself exits (Steam daemonizes and reparents
    # away from this script, so we can't wait on it directly). A short
    # bound (this used to be 10 minutes) causes the script to exit mid-game,
    # which Sunshine reads as "the app terminated" and tears down the
    # capture pipeline — killing the stream while the game keeps running
    # underneath. 24 hours comfortably outlasts any real session while
    # still eventually cleaning up if the box is left streaming unattended.
    declare -A fullscreened
    for i in {1..43200}; do
      dummy_id=$(${hyprctl} -j monitors all | ${pkgs.jq}/bin/jq -r --arg desc "${dummyPlugDesc}" '.[] | select(.description | startswith($desc)) | .id')
      if [ -n "$dummy_id" ]; then
        while read -r addr; do
          [ -z "$addr" ] && continue
          if [ -z "''${fullscreened[$addr]:-}" ]; then
            ${hyprctl} eval "hl.dispatch(hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'set', window = 'address:$addr' }))"
            fullscreened[$addr]=1
          fi
        done < <(${hyprctl} -j clients | ${pkgs.jq}/bin/jq -r --argjson mon "$dummy_id" '.[] | select(.monitor == $mon) | .address')
      fi
      sleep 2
    done
  '';

  res4ktv = mkResolutionScript "4ktv" "3840x2160@60" 3840 2160;
  resFold7 = mkResolutionScript "fold7" "modeline 557.50 2184 2232 2264 2344 1968 1971 1976 1982 +hsync -vsync" 2184 1968;
  resSteamdeck = mkResolutionScript "steamdeck" "1280x800@60" 1280 800;
in
{
  xdg.configFile."sunshine/sunshine.conf".text = builtins.concatStringsSep "\n" [
    "gamepad = x360"
    "capture = wlr"
    "output_name = ${dummyPlugConnector}"
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
          { "do" = "${res4ktv}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Desktop (Fold 7)";
        image-path = "desktop.png";
        prep-cmd = [
          { "do" = "${resFold7}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Desktop (Steam Deck)";
        image-path = "desktop.png";
        prep-cmd = [
          { "do" = "${resSteamdeck}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }

      # Steam Big Picture profiles
      {
        name = "Steam (4K TV)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${res4ktv}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Steam (Fold 7)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${resFold7}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
      {
        name = "Steam (Steam Deck)";
        cmd = "${steamBigPicture}";
        image-path = "steam.png";
        prep-cmd = [
          { "do" = "${resSteamdeck}"; undo = "${restoreScript}"; }
          { "do" = "${inhibitSuspend}"; undo = "${uninhibitSuspend}"; }
        ];
      }
    ];
  };
}
