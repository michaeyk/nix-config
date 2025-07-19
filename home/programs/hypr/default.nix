{
  config,
  pkgs,
  lib,
  hostname ? "unknown",
  ...
}: {
  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    pyprland
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
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on && random-wallpaper.sh";
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      preload = ["/home/mike/Pictures/wallpaper/wallpaper.jpeg"];
      wallpaper = ["/home/mike/Pictures/wallpaper/wallpaper.jpeg"];
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
        origin = "top-left";
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

  home.file = {
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
