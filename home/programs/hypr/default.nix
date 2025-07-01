{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    pyprland
    wl-clipboard-rs
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
        font = "Jetbrains Mono";
        frame_color = "#8aadf4";
        separator_color = "frame";
        highlight = "#8aadf4";
        enable_recursive_icon_lookup = true;
        icon_theme = "Papirus";
        min_icon_size = 24;
        max_icon_size = 64;
        icon_position = "left";
        scale = 0;
      };

      urgency_low = {
        background = "#24273a";
        foreground = "#cad3f5";
        default_icon = "dialog-information";
      };

      urgency_normal = {
        background = "#24273a";
        foreground = "#cad3f5";
        default_icon = "dialog-information";
      };

      urgency_critical = {
        background = "#24273a";
        foreground = "#cad3f5";
        frame_color = "#f5a97f";
        default_icon = "dialog-error";
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
        background = "24273add";
        text = "cad3f5ff";
        prompt = "b8c0e0ff";
        placeholder = "8087a2ff";
        input = "cad3f5ff";
        match = "8bd5caff";
        selection = "5b6078ff";
        selection-text = "cad3f5ff";
        selection-match = "8bd5caff";
        counter = "8087a2ff";
        border = "8bd5caff";
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
    ".config/waybar" = {
      source = ../waybar;
      recursive = true;
    };
  };
}
