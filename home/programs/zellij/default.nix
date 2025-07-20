{pkgs, lib, config, ...}: {
  programs.zellij = {
    enable = true;
    settings = {
      theme = "stylix";
      show_startup_tips = false;
      themes = {
        stylix = {
          bg = "#${config.lib.stylix.colors.base00}";
          fg = "#${config.lib.stylix.colors.base05}";
          black = "#${config.lib.stylix.colors.base01}";
          red = "#${config.lib.stylix.colors.base08}";
          green = "#${config.lib.stylix.colors.base0B}";
          yellow = "#${config.lib.stylix.colors.base0A}";
          blue = "#${config.lib.stylix.colors.base0D}";
          magenta = "#${config.lib.stylix.colors.base0E}";
          cyan = "#${config.lib.stylix.colors.base0C}";
          white = "#${config.lib.stylix.colors.base06}";
          orange = "#${config.lib.stylix.colors.base09}";
        };
      };
    };
  };
}