{pkgs,lib, ...}: {
  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprpicker
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
    dunst
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
        # placeholder_text = '\'<span foreground="##cad3f5">Password...</span>'\';
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
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background="24273add";
        text="cad3f5ff";
        prompt="b8c0e0ff";
        placeholder="8087a2ff";
        input="cad3f5ff";
        match="8bd5caff";
        selection="5b6078ff";
        selection-text="cad3f5ff";
        selection-match="8bd5caff";
        counter="8087a2ff";
        border="8bd5caff";
      };
    }; 
  };

  # interferes with gpg-agent, force it off
  services.gnome-keyring.enable = lib.mkForce false;

  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "/home/mike/Pictures/wallpaper";
        duration = "10m";
        queue-size = 1000;
      };
    };
  };

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
