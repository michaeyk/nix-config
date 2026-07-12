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
    (rust-bin.stable.latest.default.override {
      extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
    })
    rustlings
    gcc
    just
    gnumake
    dart-sass
    #postman
    #mongodb-compass # currently broken in nixpkgs — build errors out
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
    herdr
    pi-coding-agent
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
    rclip
    trash-cli

    # gaming
    heroic

    # git
    gh # github command line

    # lsp
    markdown-oxide

    # pdf / ebook
    calibre
    poppler-utils
    python312Packages.weasyprint
    # Curated TeX Live: just the packages pandoc's eisvogel template needs,
    # ~0.8GB vs ~7GB for the full scheme. Verified all template \usepackages
    # resolve. Add `biber` here if you ever render with --biblatex.
    (texliveSmall.withPackages (ps:
      with ps; [
        adjustbox carlisle amsmath amsfonts tools babel background beamer biblatex
        bookmark booktabs caption csquotes draftwatermark etoolbox fancyvrb float
        footmisc mdwtools footnotebackref footnotehyper framed fvextra geometry
        graphics hyperref iftex listings lm luacolor luaotfload luatexja lua-ul
        mathspec mdframed microtype multirow natbib needspace pagecolor parskip
        koma-script selnolig setspace soul sourcecodepro sourcesanspro svg pgf
        titling ucharcat unicode-math upquote xcolor xecjk xurl fontspec zref mweights
      ]))
    evince

    # remote connections
    lftp
    sshfs
    dante
    cloudflared

    # utils
    usbutils
    imsprog # CH341A EEPROM/Flash chip programmer GUI
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
