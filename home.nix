{
  config,
  pkgs,
  inputs,
  ...
}: let
  ezaParams = "--git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale";
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mike";
  home.homeDirectory = "/home/mike";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    # inputs.sops-nix.homeManagerModules.sops
    ./email
    ./helix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Adds the 'hello' command to your environment. It prints a friendly
    # "Hello, world!" when run.
    # pkgs.hello

    # archive
    zip
    unzip

    # backup
    rsync
    restic

    # browsers
    brave

    # dev
    python313
    rustup
    gcc
    just
    dart-sass

    # encryption / passwords
    gnupg
    pass
    pinentry-gtk2
    gnome-keyring
    seahorse
    libsecret
    sops

    # fonts
    nerdfonts

    # files and directories
    yazi
    fzf
    fd

    # git
    gh

    # hyprland
    hypridle
    hyprlock
    hyprpanel
    pyprland
    waybar
    wl-clipboard-rs
    fuzzel
    bemoji
    grim
    slurp
    grimblast
    swappy
    nwg-displays
    pywal
    matugen
    swww
    brightnessctl

    # lsp
    markdown-oxide
    marksman

    # media
    mpv
    vlc
    spotify
    nsxiv

    # messaging
    gajim

    # pdf
    poppler_utils
    pandoc

    # productivity
    obsidian
    libreoffice
    smartcat

    # remote connections
    lftp
    sshfs

    # utils
    ripgrep
    jq
    eza
    bat
    btop
    dust
    libgtop

    spaceship-prompt

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    # (pkgs.nerdfonts.override {fonts = ["FantasqueSansMono"];})

    # You can also create simple shell scripts directly inside your
    # configuration. For example, this adds a command 'my-hello' to your
    # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    history = {
      ignoreAllDups = true;
      extended = true;
      expireDuplicatesFirst = true;
      size = 10000;
    };
    shellAliases = {
      #some aliases here
      zj = "zellij";
      cat = "bat";
      sxiv = "nsxiv";
      lg = "lazygit";
      gcob = "git branch | fzf | xargs git checkout";

      # Add eza aliases
      ls = "eza ${ezaParams}";
      l = "eza --git-ignore ${ezaParams}";
      ll = "eza --all --header --long ${ezaParams}";
      llm = "eza --all --header --long --sort=modified ${ezaParams}";
      la = "eza -lbhHigUmuSa";
      lx = "eza -lbhHigUmuSa@";
      lt = "eza --tree ${ezaParams}";
      tree = "eza --tree ${ezaParams}";
    };

    initExtra = ''
      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      	yazi "$@" --cwd-file="$tmp"
      	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		builtin cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }

      export COPILOT_API_KEY=$(cat /run/secrets/COPILOT_API_KEY)

      source ${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme;
    '';
  };

  programs.bash.enable = true;

  programs.browserpass = {
    enable = true;
    browsers = ["firefox" "chrome" "brave"];
  };

  programs.git = {
    enable = true;
    userName = "Michael Kim";
    userEmail = "mike@michaelkim.net";

    extraConfig = {
      init.defaultBranch = "main";
      advice.addEmbeddedRepo = false;
      core = {
        editor = "${pkgs.helix}/bin/hx";
      };
    };
  };

  programs.lazygit.enable = true;

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

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
      size = 10;
    };
    settings = {
      enable_audio_bell = false;
      background = "#282828";
      background_opacity = 0.7;
    };
    themeFile = "Catppuccin-Mocha";
  };

  # services.pcscd.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

  services.syncthing.enable = true;

  services.gnome-keyring.enable = true;

  # sops = {
  #   age.keyFile = "/home/mike/.config/sops/keys.txt";
  #   defaultSopsFile = ./secrets.yaml;
  #   secrets.test = {
  #     path = "%r/test.txt";
  #   };
  # };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "default-web-browser" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
    };
  };

  programs.zathura.enable = true;

  programs.tmux.enable = true;

  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "obsidian"
      "spotify"
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/aerc" = {
      source = ./email/aerc;
      recursive = true;
    };

    ".config/hypr" = {
      source = ./hypr;
      recursive = true;
    };

    ".config/kitty" = {
      source = ./kitty;
      recursive = true;
    };

    ".config/restic" = {
      source = ./restic;
      recursive = true;
    };

    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };
  };

  home.sessionPath = ["$HOME/bin"];

  # Define systemd service to back up home directory
  systemd.user.services.restic = {
    Unit = {
      Description = "Back up home directory";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/home/mike/bin/backup.sh"; # Command to run
      Restart = "on-failure"; # Optional: restart on failure
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Define the systemd timer to run on boot
  systemd.user.timers.restic = {
    Unit = {
      Description = "Back up home directory";
    };
    Timer = {
      OnBootSec = "5m";
      OnUnitInactiveSec = "1d";
      Persistent=true;
      Unit = "restic.service";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mike/etc/profile.d/hm-session-vars.sh

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
