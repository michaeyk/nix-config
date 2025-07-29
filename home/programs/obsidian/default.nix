{pkgs, lib, config, ...}: {
  # Create Obsidian theme using Stylix colors
  home.file.".config/obsidian/themes/Stylix/theme.css" = {
    text = ''
      /* Stylix-generated theme for Obsidian */
      /* This theme automatically adapts to your Stylix color scheme */
      
      .theme-dark {
        /* Stylix Base16 color variables */
        --base00: #${config.lib.stylix.colors.base00};
        --base01: #${config.lib.stylix.colors.base01};
        --base02: #${config.lib.stylix.colors.base02};
        --base03: #${config.lib.stylix.colors.base03};
        --base04: #${config.lib.stylix.colors.base04};
        --base05: #${config.lib.stylix.colors.base05};
        --base06: #${config.lib.stylix.colors.base06};
        --base07: #${config.lib.stylix.colors.base07};
        --base08: #${config.lib.stylix.colors.base08};
        --base09: #${config.lib.stylix.colors.base09};
        --base0A: #${config.lib.stylix.colors.base0A};
        --base0B: #${config.lib.stylix.colors.base0B};
        --base0C: #${config.lib.stylix.colors.base0C};
        --base0D: #${config.lib.stylix.colors.base0D};
        --base0E: #${config.lib.stylix.colors.base0E};
        --base0F: #${config.lib.stylix.colors.base0F};
        
        /* Obsidian color mappings */
        --background-primary: var(--base00);
        --background-primary-alt: var(--base01);
        --background-secondary: var(--base01);
        --background-secondary-alt: var(--base02);
        --background-modifier-border: var(--base03);
        --background-modifier-form-field: var(--base01);
        --background-modifier-form-field-highlighted: var(--base02);
        --background-modifier-box-shadow: rgba(0, 0, 0, 0.3);
        --background-modifier-success: var(--base0B);
        --background-modifier-error: var(--base08);
        --background-modifier-cover: rgba(0, 0, 0, 0.8);
        
        /* Text colors */
        --text-normal: var(--base05);
        --text-muted: var(--base04);
        --text-faint: var(--base03);
        --text-on-accent: var(--base00);
        --text-error: var(--base08);
        --text-success: var(--base0B);
        --text-selection: var(--base02);
        --text-accent: var(--base0D);
        --text-accent-hover: var(--base0C);
        
        /* Interactive colors */
        --interactive-normal: var(--base02);
        --interactive-hover: var(--base03);
        --interactive-accent: var(--base0D);
        --interactive-accent-hover: var(--base0C);
        --interactive-success: var(--base0B);
        
        /* Scrollbar */
        --scrollbar-bg: var(--base00);
        --scrollbar-thumb-bg: var(--base03);
        --scrollbar-active-thumb-bg: var(--base04);
        
        /* Code blocks */
        --code-background: var(--base01);
        --code-normal: var(--base05);
        --code-comment: var(--base03);
        --code-function: var(--base0D);
        --code-important: var(--base08);
        --code-keyword: var(--base0E);
        --code-operator: var(--base0C);
        --code-property: var(--base0A);
        --code-punctuation: var(--base05);
        --code-string: var(--base0B);
        --code-tag: var(--base08);
        --code-value: var(--base09);
        
        /* Blockquotes */
        --blockquote-border: var(--base0C);
        
        /* Tables */
        --table-border-color: var(--base03);
        --table-header-background: var(--base01);
        --table-header-background-hover: var(--base02);
        --table-row-background-hover: var(--base01);
        
        /* Links */
        --link-color: var(--base0D);
        --link-color-hover: var(--base0C);
        --link-external-color: var(--base0C);
        --link-external-color-hover: var(--base0D);
        
        /* Tags */
        --tag-background: var(--base02);
        --tag-background-hover: var(--base03);
        --tag-color: var(--base05);
        
        /* Headers */
        --h1-color: var(--base08);
        --h2-color: var(--base09);
        --h3-color: var(--base0A);
        --h4-color: var(--base0B);
        --h5-color: var(--base0C);
        --h6-color: var(--base0D);
        
        /* Graph view colors */
        --graph-line: var(--base03);
        --graph-node: var(--base04);
        --graph-node-focused: var(--base0D);
        --graph-node-tag: var(--base0B);
        --graph-node-attachment: var(--base0A);
        --graph-node-unresolved: var(--base08);
        
        /* Font families from Stylix */
        --font-interface-override: "${config.stylix.fonts.sansSerif.name}", "Inter", sans-serif;
        --font-text-override: "${config.stylix.fonts.serif.name}", "Libertinus Serif", serif;
        --font-monospace-override: "${config.stylix.fonts.monospace.name}", "JetBrains Mono", monospace;
      }
      
      /* Additional styling improvements */
      body {
        font-family: var(--font-text-override);
      }
      
      .markdown-source-view,
      .markdown-preview-view {
        font-family: var(--font-text-override);
        font-size: ${toString (config.stylix.fonts.sizes.applications + 8)}px;
      }
      
      .cm-s-obsidian .CodeMirror-code,
      code {
        font-family: var(--font-monospace-override);
        font-size: ${toString (config.stylix.fonts.sizes.terminal + 8)}px;
      }
      
      /* UI elements use sans-serif */
      .nav-file-title,
      .nav-folder-title,
      .side-dock-ribbon,
      .side-dock-tabs,
      .workspace-tab-header,
      .status-bar,
      .suggestion-item,
      .menu {
        font-family: var(--font-interface-override);
      }
      
      /* Make the theme feel cohesive with Stylix */
      .workspace {
        background-color: var(--background-primary);
      }
      
      .workspace-ribbon {
        background-color: var(--background-secondary);
      }
      
      .workspace-tabs {
        background-color: var(--background-secondary);
      }
      
      /* Style the title bar to match */
      .titlebar {
        background-color: var(--background-secondary);
      }
      
      .titlebar-inner {
        color: var(--text-normal);
      }
    '';
  };
  
  # Create manifest.json for the theme
  home.file.".config/obsidian/themes/Stylix/manifest.json" = {
    text = builtins.toJSON {
      name = "Stylix";
      version = "1.0.0";
      minAppVersion = "0.16.0";
      author = "NixOS Stylix Integration";
      authorUrl = "https://github.com/danth/stylix";
    };
  };
  
  # Create a CSS snippet for additional Stylix customizations
  home.file.".config/obsidian/snippets/stylix-override.css" = {
    text = ''
      /* Additional Stylix theme customizations */
      .theme-dark {
        /* Use Stylix accent color */
        --interactive-accent: #${config.lib.stylix.colors.base0D};
        --interactive-accent-hover: #${config.lib.stylix.colors.base0C};
      }
      
      /* Style checkboxes with Stylix colors */
      .markdown-preview-view .task-list-item-checkbox:checked,
      .markdown-source-view .task-list-item-checkbox:checked {
        background-color: #${config.lib.stylix.colors.base0B};
        border-color: #${config.lib.stylix.colors.base0B};
      }
      
      /* Style selections */
      ::selection {
        background-color: #${config.lib.stylix.colors.base02};
        color: #${config.lib.stylix.colors.base06};
      }
    '';
  };
}
