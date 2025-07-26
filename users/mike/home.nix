{pkgs, ...}: {
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
    ../../home/core.nix
    ../../home/shell
    ../../home/programs/hypr
    ../../home/programs/email
    ../../home/programs/helix
    ../../home/programs/git
    ../../home/programs/stylix.nix
    ../../home/programs/obsidian
    ../../home/programs/zellij
    ../../home/programs/firefox.nix
  ];

  fonts.fontconfig.enable = true;

  # Environment variables for Qt theming
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # browser and webdriver
    brave
    google-chrome
    chromedriver
    geckodriver
    w3m

    # media
    mpv
    vlc
    spotify
    playerctl
    imv
    ncspot
    nsxiv

    # messaging / email
    dino
    whatsapp-for-linux
    discord

    # encryption / passwords
    pass
    pinentry-gtk2
    libsecret
    sops
    ledger-live-desktop

    # photo editing
    gimp
    krita
    photocollage

    # productivity
    obsidian
    libreoffice
    # glabels

    # Raspberry Pi
    rpi-imager

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    # (pkgs.nerdfonts.override {fonts = ["FantasqueSansMono"];})
    nerd-fonts.jetbrains-mono
    font-awesome
    jetbrains-mono

    # You can also create simple shell scripts directly inside your
    # configuration. For example, this adds a command 'my-hello' to your
    # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.browserpass = {
    enable = true;
    browsers = ["firefox" "chrome" "brave"];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  services.syncthing.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "default-web-browser" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      # "image/png" = "imv-folder.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "video/*" = "umpv.desktop";
      "audio/*" = "org.gnome.Lollypop.desktop";
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
    };
  };

  programs.zathura.enable = true;

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

  systemd.user.timers.restic = {
    Unit = {
      Description = "Back up home directory";
    };
    Timer = {
      OnBootSec = "5m";
      OnUnitInactiveSec = "1d";
      Persistent = true;
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
}
