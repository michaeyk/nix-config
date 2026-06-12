{
  config,
  pkgs,
  lib,
  hostname ? "unknown",
  ...
}: let
  # Drop-down scratchpad sizes. Hyprland's `size = exact X% Y%` rule is
  # silently overridden by kitty (uses initial_window_width/height) and GTK
  # apps (call gtk_window_set_default_size after creation); only the pixel
  # min_size/max_size clamp survives. Percentages aren't accepted there
  # (hyprwm/Hyprland#5099, "not planned"), so compute pixels per host from a
  # shared % layout. screen.{w,h} is the *logical* (post-scale) resolution.
  screen =
    if hostname == "babysnacks"
    then { w = 1440; h = 960; }   # eDP-1 2880x1920 @ scale 2
    else { w = 5120; h = 1440; }; # Samsung Odyssey G95SC @ scale 1
  pct = wp: hp: [ (screen.w * wp / 100) (screen.h * hp / 100) ];
  dropdownSize = {
    dropterm  = pct 80 60;
    yazi      = pct 75 75;
    volume    = pct 40 80;
    bluetooth = pct 32 70;
  };
in {
  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprpicker
    awww
    wl-clipboard
    cliphist
    bemoji
    grim
    slurp
    swappy
    nwg-displays
    pywal
    matugen
    brightnessctl
    gnome-bluetooth
    pavucontrol
    upower
    waybar
    wttrbar
    crypto-tracker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS module (programs.hyprland) installs the compositor + portal.
    package = null;
    portalPackage = null;
    configType = "lua";
    # UWSM handles the session on babysnacks; the systemd target HM ships
    # interferes with that and is unnecessary elsewhere too.
    systemd.enable = false;

    settings = {
      mod = { _var = "SUPER"; };

      monitor = [
        {
          # Match by description so the config survives DP port changes across reboots
          output = "desc:Samsung Electric Company Odyssey G95SC";
          mode = "5120x1440@240";
          position = "0x0";
          scale = 1;
        }
        {
          # HDMI dummy plug — disabled by default, Sunshine prep-cmd enables it for streaming.
          # Match by description: the kernel-assigned connector name (HDMI-A-1 vs -A-3)
          # has shifted across reboots/driver updates and broke the disable rule.
          output = "desc:IDV AOC28E850.HDR";
          disabled = true;
        }
        {
          # Fallback for any monitor - prevents crashes when monitor config is stale
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
      ];

      config = {
        ecosystem.no_update_news = true;

        general = {
          layout = "dwindle";
          gaps_in = 20;
          gaps_out = 40;
          border_size = 2;
          # Border colors come from stylix.targets.hyprland.
        };

        decoration = {
          rounding = 5;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
        };

        animations.enabled = true;

        dwindle.force_split = 0;

        master = {
          new_on_top = true;
          orientation = "center";
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          vrr = 2;
        };

        gestures.workspace_swipe_min_speed_to_force = 5;

        input = {
          # Remap Capslock -> Super for Vim users
          kb_options = "caps:super";
          repeat_rate = 50;
          repeat_delay = 240;
          sensitivity = 0.75;
          touchpad = {
            disable_while_typing = true;
            natural_scroll = false;
            clickfinger_behavior = true;
            middle_button_emulation = false;
            tap_to_click = true;
          };
        };
      };

      curve = {
        _args = [
          "overshot"
          {
            type = "bezier";
            points = [ [ 0.13 0.99 ] [ 0.29 1.1 ] ];
          }
        ];
      };

      animation = [
        { leaf = "windows"; enabled = true; speed = 4; bezier = "overshot"; style = "slide"; }
        { leaf = "fade"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 8.8; bezier = "overshot"; style = "slide"; }
        # Drop scratchpad special workspaces vertically from the top edge.
        { leaf = "specialWorkspace"; enabled = true; speed = 8; bezier = "overshot"; style = "slidevert"; }
        { leaf = "border"; enabled = true; speed = 14; bezier = "default"; }
      ];

      window_rule = [
        { match = { class = "^(brave-browser)$"; title = "^(Save File)$"; }; float = true; }
        { match = { class = "^(brave-browser)$"; title = "^(Open File)$"; }; float = true; }
        { match = { class = "^(brave-browser)$"; title = "^(Picture-in-Picture)$"; }; float = true; }
        { match = { class = "^(firefox)$"; title = "^(Save File)$"; }; float = true; }
        { match = { class = "^(firefox)$"; title = "^(Open File)$"; }; float = true; }
        { match = { class = "^(firefox)$"; title = "^(Picture-in-Picture)$"; }; float = true; }
        { match = { class = "^(xdg-desktop-portal-gtk)$"; }; float = true; }
        { match = { class = "^(nmtui)$"; }; float = true; }
        { match = { class = "^(btop)$"; }; float = true; size = [ 1200 800 ]; }

        # Drop-down scratchpads. Each class is auto-routed to its own special
        # workspace at the configured size; the keybinds in extraConfig below
        # spawn the app if missing and toggle the workspace. Sizes come from
        # the per-host `dropdownSize` let-binding at the top of this file.
        # NB: snake_case is the Lua plugin's spelling — `minsize`/`maxsize` (the
        # raw Hyprland keyword form) errors with "unknown field".
        { match = { class = "^(kitty-dropterm)$"; };                 float = true; min_size = dropdownSize.dropterm;  max_size = dropdownSize.dropterm;  workspace = "special:dropterm"; }
        { match = { class = "^(org\\.pulseaudio\\.pavucontrol)$"; }; float = true; min_size = dropdownSize.volume;    max_size = dropdownSize.volume;    workspace = "special:volume"; }
        { match = { class = "^(\\.blueman-manager-wrapped)$"; };     float = true; min_size = dropdownSize.bluetooth; max_size = dropdownSize.bluetooth; workspace = "special:bluetooth"; }
        { match = { class = "^(yazi)$"; };                           float = true; min_size = dropdownSize.yazi;      max_size = dropdownSize.yazi;      workspace = "special:yazi"; }

        # Send the Gajim roster to ws9. Title-restricted to "Gajim" exactly so
        # dialogs (prefs, send-file, downloads) — which share the class but have
        # different titles — stay on the current workspace.
        { match = { class = "^(org\\.gajim\\.Gajim)$"; title = "^Gajim$"; }; workspace = "9"; }
      ];
    };

    extraConfig = ''
      -- Mouse drag/resize binds
      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Apps
      hl.bind(mod .. " + B", hl.dsp.exec_cmd("brave"))
      hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))
      hl.bind(mod .. " + C", hl.dsp.exec_cmd("google-chrome-stable"))
      hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
      hl.bind(mod .. " + R", hl.dsp.exec_cmd("fuzzel"))

      -- Drop-down scratchpads. Window rules above route each class to its own
      -- named special workspace at the right size. First press spawns the app
      -- and the window rule brings the workspace in (with the slidevert
      -- animation); subsequent presses toggle visibility on/off.
      local function dropdown(pgrep_match, spawn_cmd, ws_name)
        return function()
          local pipe = io.popen("pgrep -f '" .. pgrep_match .. "'")
          local pids = pipe:read("*a")
          pipe:close()
          if pids ~= "" then
            hl.dispatch(hl.dsp.workspace.toggle_special(ws_name))
          else
            hl.exec_cmd(spawn_cmd)
          end
        end
      end
      hl.bind(mod .. " + U",         dropdown("kitty.*--class kitty-dropterm", "kitty --class kitty-dropterm", "dropterm"))
      hl.bind(mod .. " + SHIFT + V", dropdown("^pavucontrol$",                  "pavucontrol",                  "volume"))
      hl.bind(mod .. " + SHIFT + B", dropdown("blueman-manager",                "blueman-manager",              "bluetooth"))
      hl.bind(mod .. " + E",         dropdown("kitty.*--class yazi",            "kitty --class yazi -e yazi",   "yazi"))

      -- Misc launchers
      hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/hyprPicker.sh"))
      hl.bind(mod .. " + V", hl.dsp.exec_cmd("sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'"))
      hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("sh -c 'BEMOJI_PICKER_CMD=\"fuzzel -d\" bemoji'"))

      -- Window mgmt
      hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
      hl.bind(mod .. " + W", hl.dsp.window.close())
      hl.bind(mod .. " + Q", hl.dsp.exec_cmd("~/.config/waybar/scripts/fuzzel-powermenu.sh"))
      hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

      -- Layout switching
      hl.bind(mod .. " + D", function() hl.config({ general = { layout = "dwindle" } }) end)
      hl.bind(mod .. " + M", function() hl.config({ general = { layout = "master" } }) end)

      -- Media keys
      hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.config/hypr/scripts/volume mute"))
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume down"), { repeating = true })
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume up"),   { repeating = true })
      hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))

      -- Brightness
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 10%+"), { repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { repeating = true })

      -- Screenshots and recording
      hl.bind(mod .. " + S", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" /tmp/screenshot.png && swappy -f /tmp/screenshot.png && screenshot.sh'"))
      hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("sh -c 'wf-recorder -g \"$(slurp)\"'"))

      -- Lock
      hl.bind(mod .. " + Z", hl.dsp.exec_cmd("hyprlock"))

      -- Scratchpad workspace
      hl.bind(mod .. " + SHIFT + P", hl.dsp.window.move({ workspace = "special" }))
      hl.bind(mod .. " + P", hl.dsp.workspace.toggle_special())

      -- Random wallpaper
      hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("random-wallpaper.sh"))

      -- Focus (hjkl)
      hl.bind(mod .. " + h", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + l", hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + j", hl.dsp.focus({ direction = "down" }))
      hl.bind(mod .. " + k", hl.dsp.focus({ direction = "up" }))

      -- Resize active window with arrow keys
      hl.bind(mod .. " + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }))
      hl.bind(mod .. " + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }))
      hl.bind(mod .. " + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }))
      hl.bind(mod .. " + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }))

      -- Swap windows
      hl.bind(mod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
      hl.bind(mod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
      hl.bind(mod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
      hl.bind(mod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))

      -- Workspaces 1-10 (key 10 maps to "0")
      for i = 1, 10 do
        local key = i % 10
        hl.bind(mod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
      end

      -- Autostart
      hl.on("hyprland.start", function()
        -- Status bar
        hl.exec_cmd("waybar")
        hl.exec_cmd("~/.config/waybar/scripts/mpris-notifier.sh")

        hl.exec_cmd("dunst")
        hl.exec_cmd("blueman-applet")
        hl.exec_cmd("wl-paste --type text --watch cliphist store")
        hl.exec_cmd("wl-paste --type image --watch cliphist store")

        -- Wallpaper
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("sh -c 'sleep 1 && awww img /home/mike/Pictures/wallpaper/wallpaper.jpeg'")

        hl.exec_cmd("hypridle")

        hl.exec_cmd("karere")

        -- Spawn-with-rules variants need the dispatcher form.
        hl.dispatch(hl.dsp.exec_cmd("gajim", { workspace = "9 silent" }))
        hl.dispatch(hl.dsp.exec_cmd("obsidian", { workspace = "special" }))
        hl.exec_cmd("brave --new-window https://messages.google.com/web/conversations")

        -- Screen sharing
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("~/.config/hypr/scripts/screensharing.sh")
      end)
    '';
  };

  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      disable_loading_bar = true;
      grace = 300;
      hide_cursor = true;
      no_fade_in = false;
    };

    background = [
      {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }
    ];

    input-field = [
      {
        size = "200, 50";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgb(91, 96, 120)";
        outer_color = "rgb(24, 25, 38)";
        outline_thickness = 5;
        shadow_passes = 2;
      }
    ];
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on; loginctl unlock-session; sleep 1; loginctl lock-session";
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "[ -f /tmp/sunshine-streaming ] || (pidof hyprlock || hyprlock)";
        }
        {
          # DPMS off before suspend - helps NVIDIA resume properly
          timeout = 1140;
          on-timeout = "[ -f /tmp/sunshine-streaming ] || hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1200;
          on-timeout = "[ -f /tmp/sunshine-streaming ] || systemctl suspend";
        }
      ];
    };
  };


  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
      size = "32x32";
    };

    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "bottom-right";
        transparency = 10;
        font = lib.mkDefault "Jetbrains Mono";
        frame_color = lib.mkDefault "#8aadf4";
        separator_color = lib.mkDefault "frame";
        highlight = lib.mkDefault "#8aadf4";
        enable_recursive_icon_lookup = true;
        icon_theme = "Papirus";
        min_icon_size = 24;
        max_icon_size = 64;
        icon_position = "left";
        script = "~/.config/waybar/scripts/notification-tracker.sh --increment";
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
        scale = 0;
      };

      urgency_low = {
        background = lib.mkDefault "#24273a";
        foreground = lib.mkDefault "#cad3f5";
        default_icon = lib.mkDefault "dialog-information";
      };

      urgency_normal = {
        background = lib.mkDefault "#24273a";
        foreground = lib.mkDefault "#cad3f5";
        default_icon = lib.mkDefault "dialog-information";
      };

      urgency_critical = {
        background = lib.mkDefault "#24273a";
        foreground = lib.mkDefault "#cad3f5";
        frame_color = lib.mkDefault "#f5a97f";
        default_icon = lib.mkDefault "dialog-error";
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };

      firefox = {
        appname = "Firefox";
        desktop_entry = "firefox";
        icon = "firefox";
      };

      spotify = {
        appname = "Spotify";
        desktop_entry = "spotify";
        icon = "spotify";
      };

      thunderbird = {
        appname = "Thunderbird";
        desktop_entry = "thunderbird";
        icon = "thunderbird";
      };

      error_notifications = {
        summary = "*error*";
        icon = "dialog-error";
        urgency = "critical";
      };

      warning_notifications = {
        summary = "*warning*";
        icon = "dialog-warning";
        urgency = "normal";
      };

      success_notifications = {
        summary = "*success*";
        icon = "dialog-ok";
        urgency = "low";
      };

      battery_notifications = {
        summary = "*battery*";
        icon = "battery";
      };

      volume_notifications = {
        summary = "*volume*";
        icon = "audio-volume-high";
      };

      network_notifications = {
        summary = "*network*";
        icon = "network-wireless";
      };

      bluetooth_notifications = {
        summary = "*bluetooth*";
        icon = "bluetooth";
      };

      screenshot_notifications = {
        summary = "*screenshot*";
        icon = "camera-photo";
      };

      download_notifications = {
        summary = "*download*";
        icon = "folder-download";
      };

      update_notifications = {
        summary = "*update*";
        icon = "system-software-update";
      };

      yubikey_notifications = {
        appname = "yubikey-touch-detector";
        timeout = 5000;
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background = lib.mkDefault "24273add";
        text = lib.mkDefault "cad3f5ff";
        prompt = lib.mkDefault "b8c0e0ff";
        placeholder = lib.mkDefault "8087a2ff";
        input = lib.mkDefault "cad3f5ff";
        match = lib.mkDefault "8bd5caff";
        selection = lib.mkDefault "5b6078ff";
        selection-text = lib.mkDefault "cad3f5ff";
        selection-match = lib.mkDefault "8bd5caff";
        counter = lib.mkDefault "8087a2ff";
        border = lib.mkDefault "8bd5caff";
      };
    };
  };

  # interferes with gpg-agent, force it off
  services.gnome-keyring.enable = lib.mkForce false;

  # Fallback for NVIDIA resume - systemd is more reliable than hypridle's after_sleep_cmd
  systemd.user.services.hyprland-resume = {
    Unit = {
      Description = "Turn on DPMS after resume from suspend";
      After = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && hyprctl dispatch dpms on'";
    };
    Install = {
      WantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    };
  };

  home.file = {
    # Scripts, wallpapers, egpu/igpu symlinks.
    # hyprland.lua is generated by wayland.windowManager.hyprland above.
    ".config/hypr" = {
      source = ./config;
      recursive = true;
    };
    ".config/waybar/scripts" = {
      source = ../waybar/scripts;
      recursive = true;
    };
    ".config/waybar/config" = {
      text = import ../waybar/generate-config.nix {
        inherit lib hostname;
      };
    };
    ".config/waybar/style.css" = {
      text =
        let
          waybarCSS = builtins.readFile ../waybar/style.css;
          # Replace CSS variables with actual stylix colors
          processedCSS = builtins.replaceStrings [
            "var(--stylix-base00)" "var(--stylix-base01)" "var(--stylix-base02)" "var(--stylix-base03)"
            "var(--stylix-base04)" "var(--stylix-base05)" "var(--stylix-base06)" "var(--stylix-base07)"
            "var(--stylix-base08)" "var(--stylix-base09)" "var(--stylix-base0A)" "var(--stylix-base0B)"
            "var(--stylix-base0C)" "var(--stylix-base0D)" "var(--stylix-base0E)" "var(--stylix-base0F)"
          ] [
            "#${config.lib.stylix.colors.base00}" "#${config.lib.stylix.colors.base01}" "#${config.lib.stylix.colors.base02}" "#${config.lib.stylix.colors.base03}"
            "#${config.lib.stylix.colors.base04}" "#${config.lib.stylix.colors.base05}" "#${config.lib.stylix.colors.base06}" "#${config.lib.stylix.colors.base07}"
            "#${config.lib.stylix.colors.base08}" "#${config.lib.stylix.colors.base09}" "#${config.lib.stylix.colors.base0A}" "#${config.lib.stylix.colors.base0B}"
            "#${config.lib.stylix.colors.base0C}" "#${config.lib.stylix.colors.base0D}" "#${config.lib.stylix.colors.base0E}" "#${config.lib.stylix.colors.base0F}"
          ] waybarCSS;
        in
        processedCSS;
    };
  };
}
