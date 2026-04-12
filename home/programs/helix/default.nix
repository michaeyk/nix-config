{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.packages = with pkgs; [
    basedpyright
    ruff
    taplo
    dprint
    black
    typescript-language-server
    (lib.hiPrio prettier)
    # lsp-ai
    markdown-oxide
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
        mouse = true;
        scroll-lines = 1;
        rulers = [80 120];
        auto-format = true;
        auto-save = true;
        auto-pairs = true;
        cursorline = true;
        bufferline = "always";
        soft-wrap = {
          enable = true;
        };
        statusline = {
          left = ["mode" "spinner" "diagnostics"];
          center = ["file-name" "separator" "version-control" "separator"];
          right = ["position" "position-percentage" "total-line-numbers"];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };
        indent-guides = {
          render = true;
          character = "╎"; # Some characters that work well: "▏", "┆", "┊", "⸽"
          skip-levels = 1;
        };
        file-picker = {
          hidden = false;
          git-ignore = true;
          git-global = true;
          git-exclude = true;
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "block";
        };
      };

      keys = {
        normal = {
          ret = "goto_word";
          space = {
            w = ":write";
            r = ":reload-all";
          };
          H = ":bp";
          L = ":bn";
          D = ["ensure_selections_forward" "extend_to_line_end"];
          C-y = ":sh zellij run -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash ~/.config/helix/yazi-picker.sh";
          C-e = ":sh zellij run -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash ~/.config/helix/yazi-picker.sh";
          Z = {
            Z = ":x";
          };
          space.P = ["select_all" ":pipe-to pandoc -o %sh{echo \"$PWD/$(basename '%{buffer_name}' | sed 's/\\.[^.]*$/.pdf/')\"} --pdf-engine=weasyprint" "collapse_selection"];
        };
      };
    };
  };

  # yazi shell script
  home.file.".config/helix/yazi-picker.sh" = {
    text = ''
      #!/usr/bin/env bash

      paths=$(yazi --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)

      if [[ -n "$paths" ]]; then
      	zellij action toggle-floating-panes
      	zellij action write 27 # send <Escape> key
      	zellij action write-chars ":open $paths"
      	zellij action write 13 # send <Enter> key
      	zellij action toggle-floating-panes
      fi

      zellij action close-pane
    '';
  };

  # Configure LSP
  home.file.".config/helix/languages.toml" = {
    text = ''
      [[language]]
      name = "python"
      language-servers = ["basedpyright", "ruff"]
      # formatter = { command = "bash", args = ["-c", "ruff check --fix - | ruff format -"] }
      formatter = { command = "black", args = ["--quiet", "-"] }
      auto-format = true

      [[language]]
      name = "rust"
      language-servers = ["rust-analyzer"]
      auto-format = true

      [[language]]
      name = "nix"
      language-servers = ["nixd"]
      formatter = { command = "${pkgs.alejandra}/bin/alejandra" }

      [[language]]
      name = "toml"
      formatter = { command = "${pkgs.taplo}/bin/taplo", args = ["fmt", "-"] }
      auto-format = true

      [[language]]
      name = "markdown"
      language-servers = ["markdown-oxide"]
      formatter = { command = "${pkgs.dprint}/bin/dprint", args = ["fmt", "--config", "~/.config/dprint/dprint.json", "--stdin", "md"] }
      auto-format = true

      [[language]]
      name = "html"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "html"] }

      [[language]]
      name = "json"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "json"] }

      [[language]]
      name = "css"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "css"] }

      [[language]]
      name = "javascript"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "typescript"] }
      language-servers = ["typescript-language-server"]
      auto-format = true

      [[language]]
      name = "typescript"
      auto-format = true
      language-servers = ["typescript-language-server"]
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "typescript"] }

      [[language]]
      name = "tsx"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "typescript"] }
      auto-format = true

      [[language]]
      name = "jsx"
      formatter = { command = "${pkgs.prettier}/bin/prettier", args = ["--parser", "typescript"] }
      auto-format = true

      [language-server.basedpyright]
      command = "${pkgs.basedpyright}/bin/basedpyright-langserver"
      args = ["--stdio"]

      [language-server.basedpyright.config.basedpyright.analysis]
      autoSearchPaths = true
      typeCheckingMode = "basic"
      diagnosticMode = "openFilesOnly"

      [language-server.ruff]
      command = "${pkgs.ruff}/bin/ruff"
      args = ["server", "--preview"]

      [language-server.nixd]
      command = "${pkgs.nixd}/bin/nixd"

    '';
  };
}
