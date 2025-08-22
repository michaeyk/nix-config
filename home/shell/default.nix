{
  pkgs,
  lib,
  config,
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
      # Add nix-profile bin to PATH
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Add npm global packages to PATH
      export PATH="$HOME/.npm-global/bin:$PATH"

      # Source home-manager session variables
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      elif [ -f "$HOME/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh"
      elif [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi

      # Source fzf key bindings
      if [ -f "$HOME/.nix-profile/share/fzf/key-bindings.zsh" ]; then
        source "$HOME/.nix-profile/share/fzf/key-bindings.zsh"
      fi
      if [ -f "$HOME/.nix-profile/share/fzf/completion.zsh" ]; then
        source "$HOME/.nix-profile/share/fzf/completion.zsh"
      fi

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

  programs.bash = {
    enable = true;
    initExtra = ''
      # Add nix-profile bin to PATH
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Add npm global packages to PATH
      export PATH="$HOME/.npm-global/bin:$PATH"

      # Source home-manager session variables
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      elif [ -f "$HOME/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh"
      elif [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi

      # Source fzf key bindings for bash
      if [ -f "$HOME/.nix-profile/share/fzf/key-bindings.bash" ]; then
        source "$HOME/.nix-profile/share/fzf/key-bindings.bash"
      fi
      if [ -f "$HOME/.nix-profile/share/fzf/completion.bash" ]; then
        source "$HOME/.nix-profile/share/fzf/completion.bash"
      fi
    '';
  };

  programs = {
    nushell = {
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      # configFile.source = ./.../config.nu;
      # for editing directly to config.nu
      extraConfig = ''
        let carapace_completer = {|spans|
        carapace $spans.0 nushell ...$spans | from json
        }
        $env.config = {
         show_banner: false,
         completions: {
         case_sensitive: false # case-sensitive completions
         quick: true    # set to false to prevent auto-selecting completions
         partial: true    # set to false to prevent partial filling of the prompt
         algorithm: "fuzzy"    # prefix or fuzzy
         external: {
         # set to false to prevent nushell looking into $env.PATH to find more suggestions
             enable: true
         # set to lower can improve completion performance at the cost of omitting some options
             max_results: 100
             completer: $carapace_completer # check 'carapace_completer'
           }
         }
        }
        $env.PATH = ($env.PATH |
        split row (char esep) |
        prepend /home/myuser/.apps |
        append /usr/bin/env
        )
      '';
      shellAliases = {
        # vi = "hx";
        # vim = "hx";
        # nano = "hx";
      };
    };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  home.sessionPath = ["$HOME/bin"];

  programs.fzf.enableZshIntegration = true;

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
    settings = {
      plugin = {
        prepend_previewers = [
          {
            name = "*.md";
            run = "code";
          }
        ];
      };
      preview = {
        image_bound = [10000 10000];
      };
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
  };
}
