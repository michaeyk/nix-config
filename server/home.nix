{ config, pkgs, ... }: let
  ezaParams = "--git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale";
in  {
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
  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    ../helix
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

    # browser and webdriver
    w3m

    # dev
    python313
    rustup
    gcc
    just
    dart-sass

    # encryption / passwords
    libsecret
    sops

    # files and directories
    yazi
    fzf
    fd

    # git
    gh

    # lsp
    markdown-oxide
    marksman

    # pdf
    poppler_utils
    pandoc
    
    # productivity
    smartcat
    tealdeer

    # remote connections
    lftp
    sshfs
    dante

    # utils
    ripgrep
    jq
    eza
    bat
    btop
    dust
    libgtop
    ffmpeg

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

      # docker alias
      dp = "docker ps";
      dl = "docker logs --tail 10 --follow";
      dc = "docker-compose up -d";
      ds = "docker stop";

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

      source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    '';
  };

  programs.bash.enable = true;

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


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
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
  #
  home.sessionVariables = {
    EDITOR = "hx";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
