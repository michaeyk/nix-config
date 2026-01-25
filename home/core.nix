{
  pkgs,
  nurPkgs,
  ...
}: {
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
    codex
    gemini-cli
    nurPkgs.repos.charmbracelet.crush
    eslint
    nodejs

    # encryption / passwords
    cryptsetup
    pass
    pinentry-gtk2
    libsecret
    sops
    ledger-live-desktop
    qrencode

    # files and directories
    fzf
    fd
    lsof

    # gaming
    heroic

    # git
    gh # github command line

    # lsp
    markdown-oxide

    # pdf
    poppler-utils
    python312Packages.weasyprint
    texlive.combined.scheme-full
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
    mdcat
    spaceship-prompt
    killall
    fastfetch
    bc
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Pandoc
  programs.pandoc = {
    enable = true;
    defaults.pdf-engine = "weasyprint";
    templates = {
      "default.latex" = ./programs/eisvogel.latex;
    };
  };
}
