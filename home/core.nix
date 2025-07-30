{pkgs, ...}: {
  home.packages = with pkgs; [
    # archive
    zip
    unzip

    # backup
    rsync
    restic

    # browser and webdriver
    chromedriver
    geckodriver
    w3m

    # dev
    python313
    uv
    rustup
    gcc
    just
    gnumake
    dart-sass
    #postman
    mongodb-compass
    cargo-lambda
    openssl
    foundry
    postgresql
    awscli2
    smartcat
    tealdeer
    visidata
    claude-code
    gemini-cli
    eslint

    # encryption / passwords
    pass
    pinentry-gtk2
    libsecret
    sops
    ledger-live-desktop
    qrencode

    # files and directories
    fzf
    fd

    # gaming
    heroic

    # git
    gh # github command line

    # lsp
    markdown-oxide
    marksman

    # pdf
    poppler_utils
    pandoc
    evince
    
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
    ripdrag
    mailutils
    glow
    spaceship-prompt
    killall
    fastfetch
    bc
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
