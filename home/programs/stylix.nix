{pkgs, lib, config, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    
    # Set the wallpaper image - use fetchurl or copy to the dotfiles
    image = ./stylix-wallpaper.jpeg;
    
    # Base16 color scheme - you can change this to any base16 scheme
    # Popular options: catppuccin-mocha.yaml, gruvbox-dark-hard.yaml, dracula.yaml, nord.yaml
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/spaceduck.yaml";
    
    # Configure polarity (dark/light theme)
    polarity = "dark";
    
    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.libertinus;
        name = "Libertinus Serif";
      };
      sizes = {
        applications = 11;
        terminal = 10;
        desktop = 11;
        popups = 11;
      };
    };
    
    # Opacity settings
    opacity = {
      applications = 1.0;
      terminal = 0.7;
      desktop = 1.0;
      popups = 1.0;
    };
    
    # Cursor configuration
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    
    # Target applications for theming - all major apps enabled
    targets = {
      # All applications successfully themed with Stylix
      gtk.enable = true;        # GTK applications
      hyprland.enable = true;   # Hyprland window manager
      waybar.enable = false;    # Disable - use custom CSS with stylix colors
      kitty.enable = true;      # Terminal emulator
      helix.enable = true;      # Text editor
      fuzzel.enable = true;     # Application launcher
      firefox = {
        enable = true;
        profileNames = [ "default" ];  # Match the profile name from firefox.nix
      };
      dunst.enable = true;      # Notification daemon
      btop.enable = true;       # System monitor
      cava.enable = true;       # Audio visualizer
      fzf.enable = true;        # Fuzzy finder
      hyprlock.enable = false;  # Screen locker - disabled due to custom config
      hyprpaper.enable = true;  # Wallpaper daemon
      ncspot.enable = true;     # Spotify TUI client
      zathura.enable = true;    # Document viewer
    };
  };

  # Qt theme configuration for Qt-based applications (Discord, VLC, Spotify, LibreOffice)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Waybar styling with stylix colors is now managed in hypr/default.nix

  # Custom Brave browser theming using Stylix colors
  # Since Stylix doesn't have a built-in Brave target, we create custom configs
  
  # Create a Chrome theme manifest for Brave
  home.file.".config/brave-themes/stylix-theme/manifest.json" = {
    text = builtins.toJSON {
      manifest_version = 3;
      name = "Stylix Catppuccin Theme";
      version = "1.0";
      description = "Auto-generated theme using Stylix colors";
      theme = {
        colors = {
          # Use Stylix color palette for comprehensive Brave theming
          frame = [ 30 30 46 ];  # base00 converted to RGB
          frame_inactive = [ 24 24 37 ];  # base01
          frame_incognito = [ 24 24 37 ];
          frame_incognito_inactive = [ 49 50 68 ];  # base02
          toolbar = [ 30 30 46 ];
          tab_text = [ 205 214 244 ];  # base05
          tab_background_text = [ 88 91 112 ];  # base04
          bookmark_text = [ 205 214 244 ];
          ntp_background = [ 30 30 46 ];
          ntp_text = [ 205 214 244 ];
          ntp_link = [ 137 180 250 ];  # base0D
          ntp_section = [ 49 50 68 ];
          button_background = [ 49 50 68 ];
          omnibox_text = [ 205 214 244 ];
          omnibox_background = [ 24 24 37 ];
        };
        tints = {
          buttons = [ 0.26 0.26 0.26 ];
        };
      };
    };
  };

  # Create CSS for web content theming via extension
  home.file.".config/brave-themes/stylix-theme/content.css" = {
    text = ''
      /* Stylix-generated CSS for web content theming */
      :root {
        --stylix-base00: #${config.lib.stylix.colors.base00};
        --stylix-base01: #${config.lib.stylix.colors.base01};
        --stylix-base02: #${config.lib.stylix.colors.base02};
        --stylix-base03: #${config.lib.stylix.colors.base03};
        --stylix-base04: #${config.lib.stylix.colors.base04};
        --stylix-base05: #${config.lib.stylix.colors.base05};
        --stylix-base06: #${config.lib.stylix.colors.base06};
        --stylix-base07: #${config.lib.stylix.colors.base07};
        --stylix-base08: #${config.lib.stylix.colors.base08};
        --stylix-base09: #${config.lib.stylix.colors.base09};
        --stylix-base0A: #${config.lib.stylix.colors.base0A};
        --stylix-base0B: #${config.lib.stylix.colors.base0B};
        --stylix-base0C: #${config.lib.stylix.colors.base0C};
        --stylix-base0D: #${config.lib.stylix.colors.base0D};
        --stylix-base0E: #${config.lib.stylix.colors.base0E};
        --stylix-base0F: #${config.lib.stylix.colors.base0F};
      }

      /* Dark mode preference */
      @media (prefers-color-scheme: dark) {
        :root {
          color-scheme: dark;
        }
      }
    '';
  };

  # Create a userContent.css for additional Brave theming
  home.file.".config/brave/userContent.css" = {
    text = ''
      /* Brave Custom Theme using Stylix colors */
      @-moz-document url-prefix(chrome://), url-prefix(brave://), url-prefix(about:) {
        :root {
          --base00: #${config.lib.stylix.colors.base00} !important;
          --base01: #${config.lib.stylix.colors.base01} !important;
          --base02: #${config.lib.stylix.colors.base02} !important;
          --base03: #${config.lib.stylix.colors.base03} !important;
          --base04: #${config.lib.stylix.colors.base04} !important;
          --base05: #${config.lib.stylix.colors.base05} !important;
          --base06: #${config.lib.stylix.colors.base06} !important;
          --base07: #${config.lib.stylix.colors.base07} !important;
          --base08: #${config.lib.stylix.colors.base08} !important;
          --base09: #${config.lib.stylix.colors.base09} !important;
          --base0A: #${config.lib.stylix.colors.base0A} !important;
          --base0B: #${config.lib.stylix.colors.base0B} !important;
          --base0C: #${config.lib.stylix.colors.base0C} !important;
          --base0D: #${config.lib.stylix.colors.base0D} !important;
          --base0E: #${config.lib.stylix.colors.base0E} !important;
          --base0F: #${config.lib.stylix.colors.base0F} !important;
        }

        /* Apply dark theme colors */
        * {
          color-scheme: dark !important;
        }

        body {
          background-color: var(--base00) !important;
          color: var(--base05) !important;
        }

        /* Style various UI elements */
        input, textarea, select {
          background-color: var(--base01) !important;
          color: var(--base05) !important;
          border-color: var(--base03) !important;
        }

        /* Style buttons and links */
        button, .button, a {
          background-color: var(--base02) !important;
          color: var(--base05) !important;
          border-color: var(--base03) !important;
        }

        button:hover, .button:hover, a:hover {
          background-color: var(--base03) !important;
        }
      }
    '';
  };

  # Create a script to help install the Brave theme
  home.file."bin/install-brave-stylix-theme" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # Script to help install Stylix theme for Brave browser
      echo "Installing Stylix theme for Brave browser..."
      
      # Check if Brave is installed
      if ! command -v brave &> /dev/null; then
          echo "Error: Brave browser is not installed or not in PATH"
          exit 1
      fi
      
      THEME_SOURCE="$HOME/.config/brave-themes/stylix-theme"
      
      # Find Brave's extension directory
      BRAVE_CONFIG_DIRS=(
          "$HOME/.config/BraveSoftware/Brave-Browser"
          "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"
      )
      
      BRAVE_CONFIG=""
      for dir in "''${BRAVE_CONFIG_DIRS[@]}"; do
          if [ -d "$dir" ]; then
              BRAVE_CONFIG="$dir"
              break
          fi
      done
      
      if [ -z "$BRAVE_CONFIG" ]; then
          echo "Error: Could not find Brave browser configuration directory"
          echo "Please ensure Brave has been run at least once"
          exit 1
      fi
      
      # Create themes directory if it doesn't exist
      THEMES_DIR="$BRAVE_CONFIG/themes"
      mkdir -p "$THEMES_DIR"
      
      # Copy theme files
      if [ -d "$THEME_SOURCE" ]; then
          cp -r "$THEME_SOURCE" "$THEMES_DIR/"
          echo "✓ Stylix theme files copied to Brave themes directory"
          echo "  Location: $THEMES_DIR/stylix-theme"
          echo ""
          echo "To apply the theme:"
          echo "1. Open Brave browser"
          echo "2. Go to brave://settings/appearance"
          echo "3. Click 'Themes' and select 'Stylix Catppuccin Theme'"
          echo ""
          echo "Note: You may need to restart Brave for the theme to appear"
      else
          echo "Error: Theme source directory not found at $THEME_SOURCE"
          echo "Please ensure home-manager has been applied correctly"
          exit 1
      fi
    '';
  };
}
