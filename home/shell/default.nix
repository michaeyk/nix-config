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

      # AI agent protection aliases
      claude = "_ai_protected claude";
      codex = "_ai_protected codex";
      aider = "_ai_protected aider";
      cursor = "_ai_protected cursor";
      copilot = "_ai_protected copilot";

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
      # AI agent protection function
      function _ai_protected() {
        local current_dir=$(pwd)
        local no_ai_dir="$HOME/no-ai"

        # Check if current directory is within ~/no-ai
        if [[ "$current_dir" == "$no_ai_dir"* ]]; then
          echo "Error: AI coding agents are not allowed in the ~/no-ai directory tree"
          echo "Current directory: $current_dir"
          return 1
        fi

        # Run the actual command if not in restricted area
        command "$@"
      }

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
    shellAliases = {
      # AI agent protection aliases
      claude = "_ai_protected claude";
      codex = "_ai_protected codex";
      aider = "_ai_protected aider";
      cursor = "_ai_protected cursor";
      copilot = "_ai_protected copilot";
    };
    initExtra = ''
      # AI agent protection function
      function _ai_protected() {
        local current_dir=$(pwd)
        local no_ai_dir="$HOME/no-ai"

        # Check if current directory is within ~/no-ai
        if [[ "$current_dir" == "$no_ai_dir"* ]]; then
          echo "Error: AI coding agents are not allowed in the ~/no-ai directory tree"
          echo "Current directory: $current_dir"
          return 1
        fi

        # Run the actual command if not in restricted area
        command "$@"
      }

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
      "4B8632E0A2698E0CCB84DA4B1C7F0D56870ECCA9"
    ];
    defaultCacheTtl = 1800;
  };


  # Refresh GPG YubiKey connection at login
  systemd.user.services.gpg-yubikey-login = {
    Unit = {
      Description = "Refresh GPG YubiKey connection at login";
      After = [ "gpg-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "gpg-yubikey-login" ''
        # Wait for YubiKey USB device (vendor 1050 = Yubico) to appear
        for i in $(seq 1 30); do
          if ${pkgs.coreutils}/bin/ls /sys/bus/usb/devices/*/idVendor 2>/dev/null | \
             ${pkgs.findutils}/bin/xargs -I{} ${pkgs.coreutils}/bin/cat {} 2>/dev/null | \
             ${pkgs.gnugrep}/bin/grep -q "1050"; then
            break
          fi
          sleep 0.5
        done

        # Kill scdaemon to clear any stale state
        ${pkgs.gnupg}/bin/gpgconf --kill scdaemon

        # Give pcscd time to detect the reader
        sleep 1

        # Wait for card to be accessible (up to 10 seconds)
        for i in $(seq 1 20); do
          if ${pkgs.gnupg}/bin/gpg --card-status > /dev/null 2>&1; then
            exit 0
          fi
          sleep 0.5
        done
      ''}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
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
    enableDefaultConfig = false;
    extraConfig = '''';
    matchBlocks = {
      "*" = {
        # Explicitly set default values we want to keep
        sendEnv = ["LANG" "LC_*"];
        extraOptions = {
          HashKnownHosts = "yes";
        };
      };
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
