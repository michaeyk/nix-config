{pkgs, lib, config, ...}: let
  ezaParams = "--git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale";
in {
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
      ssh = "TERM=tmux ssh";

      # Add eza aliases
      ls = "eza ${ezaParams}";
      l = "eza --git-ignore ${ezaParams}";
      ll = "eza --all --header --long ${ezaParams}";
      llm = "eza --all --header --long --sort=modified ${ezaParams}";
      la = "eza -lbhHigUmuSa";
      lx = "eza -lbhHigUmuSa@";
      lt = "eza --tree ${ezaParams}";
      tree = "eza --tree ${ezaParams}";

      # docker alias
      dp = "docker ps";
      dl = "docker logs --tail 10 --follow";
      dc = "docker-compose up -d";
      ds = "docker stop";
    };

    initContent = ''
      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      	yazi "$@" --cwd-file="$tmp"
      	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		builtin cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }

      export HISTFILE="$HOME/.zsh_history"
      export COPILOT_API_KEY=$(cat /run/secrets/COPILOT_API_KEY)
      export ANTHROPIC_API_KEY=$(cat /run/secrets/ANTHROPIC_API_KEY)
      export LESS="-XR"
      export UV_PYTHON_DOWNLOADS=never

      source ${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme;
    '';
  };

  programs.fzf.enableZshIntegration = true;

  home.sessionPath = ["$HOME/bin"];

  programs.bash.enable = true;

  programs.tmux.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;
    enableSshSupport = true;
    enableScDaemon = true;
    sshKeys = [
      "49E43BE49828EA153BD936C8115CB619D9542E25"
    ];
    defaultCacheTtl = 1800;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = lib.mkDefault "Jetbrains Mono";
      package = lib.mkDefault pkgs.jetbrains-mono;
      size = lib.mkDefault 10;
    };
    # font = {
    #   name = "Fira Code";
    #   package = pkgs.fira-code;
    #   size = 10;
    # };
    settings = {
      enable_audio_bell = false;
      background = lib.mkDefault "#282828";
      background_opacity = lib.mkDefault 0.5;
    };
    themeFile = lib.mkDefault "Catppuccin-Mocha";
  };

  programs.cava = {
    enable = true;
    settings = {
      general.framerate = 60;
      # input.method = "alsa";
      smoothing.noise_reduction = 88;
      color = {
        gradient = 1;

        gradient_color_1 = "'#94e2d5'";
        gradient_color_2 = "'#89dceb'";
        gradient_color_3 = "'#74c7ec'";
        gradient_color_4 = "'#89b4fa'";
        gradient_color_5 = "'#cba6f7'";
        gradient_color_6 = "'#f5c2e7'";
        gradient_color_7 = "'#eba0ac'";
        gradient_color_8 = "'#f38ba8'";
      };
    };
  };

  programs.yazi = {
    enable = true;
    keymap = {
      mgr.prepend_keymap = [
        {
          run = "plugin diff";
          on = ["<C-d>"];
        }
        {
          run = "shell -- for path in \"$@\"; do echo \"file://\$path\"; done | wl-copy -t text/uri-list";
          on = ["Y"];
          mode = ["normal"];
        }
      ];
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      bastion = {
        port = 22;
        hostname = "34.197.186.111";
        user = "mike";
        forwardAgent = true;
      };
      jbastion = {
        port = 22;
        hostname = "3.208.183.51";
        user = "mike";
        forwardAgent = true;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      update_check = false;
      search_mode = "fuzzy";
      filter_mode_shell_up_key_binding = "session";
      style = "compact";
      show_preview = true;
      max_preview_height = 4;
      sync_address = "http://michaelkim.net:8888";
      sync_frequency = "5m";
      history_filter = [
        "^secret-tool"
        "^pass"
      ];
      history_file = "~/.zsh_history";
    };
  };

  home.file = {
    "bin" = {
      source = ./bin;
      recursive = true;
    };

    ".config/kitty" = {
      source = ../programs/kitty;
      recursive = true;
    };

    ".config/restic" = {
      source = ../programs/restic;
      recursive = true;
    };

    ".config/smartcat" = {
      source = ../programs/smartcat;
      recursive = true;
    };

    ".config/tealdeer/config.toml".text = ''
      [updates]
      auto_update = true
    '';

    ".config/yazi" = {
      source = ../programs/yazi;
      recursive = true;
    };
  };
}

