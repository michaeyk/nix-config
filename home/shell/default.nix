{
  pkgs,
  ...
}: let
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
      path = "$HOME/.zsh_history";
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
      dc = "docker compose up -d";
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

      export COPILOT_API_KEY=$(cat /run/secrets/COPILOT_API_KEY)
      export ANTHROPIC_API_KEY=$(cat /run/secrets/ANTHROPIC_API_KEY)
      export LESS="-XR"
      export UV_PYTHON_DOWNLOADS=never

      source ${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme;
    '';
  };

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
      "534D47E4DE15638C320F1DF916AD55A5D6B92A63"
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
      name = "Jetbrains Mono";
      package = pkgs.jetbrains-mono;
      size = 10;
    };
    # font = {
    #   name = "Fira Code";
    #   package = pkgs.fira-code;
    #   size = 10;
    # };
    settings = {
      enable_audio_bell = false;
      background = "#282828";
      background_opacity = 0.5;
    };
    themeFile = "Catppuccin-Mocha";
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
        hostname = "3.208.183.51";
        user = "mike";
        forwardAgent = true;
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      show_startup_tips = false;
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
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
