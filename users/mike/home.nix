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
    ../../home/programs/dprint.nix
    ../../home/programs/herdr
    ../../home/programs/pi
  ];

  fonts.fontconfig.enable = true;

  # Qt/KDE apps are themed by `stylix.targets.qt` (platform = qtct + Kvantum),
  # which applies the base16 palette and manages QT_QPA_PLATFORMTHEME itself — so
  # no QT_STYLE_OVERRIDE here (it would force adwaita over the Kvantum theme).
  #
  # GSETTINGS_SCHEMA_DIR is now vestigial: it was the companion to the old
  # platformTheme = "gtk3", where qgtk3 opened native GTK file dialogs that
  # aborted with "No GSettings schemas installed" unless the GTK + desktop
  # schemas were on the path. Under qtct, Qt uses its own dialogs and never hits
  # that call. Kept as harmless belt-and-suspenders; safe to delete later.
  home.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
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
    mp3gain

    # chat
    gajim
    dino
    zapzap
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
    libreoffice-fresh
    # glabels

    # Raspberry Pi
    # rpi-imager


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
    (pkgs.writeShellScriptBin "thinkorswim" ''
      exec flatpak run com.tdameritrade.ThinkOrSwim "$@"
    '')
    (pkgs.writeShellScriptBin "tws" ''
      exec steam-run "$HOME/Jts/1044/tws" "$@"
    '')
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
      "default-web-browser" = ["brave-browser.desktop"];
      "text/html" = ["brave-browser.desktop"];
      # "image/png" = "imv-folder.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "video/*" = "umpv.desktop";
      "audio/*" = "org.gnome.Lollypop.desktop";
      "x-scheme-handler/https" = ["brave-browser.desktop"];
      "x-scheme-handler/http" = ["brave-browser.desktop"];
      "x-scheme-handler/about" = ["brave-browser.desktop"];
      "x-scheme-handler/unknown" = ["brave-browser.desktop"];
    };
  };

  programs.zathura.enable = true;

  # Timer-driven backup only. Do not install this into default.target: Home
  # Manager activation/rebuilds would otherwise start the backup immediately,
  # which can outlive switch-to-configuration's systemd post-reload timeout.
  systemd.user.services.restic = {
    Unit = {
      Description = "Back up home directory";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/home/mike/bin/backup.sh"; # Command to run
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
