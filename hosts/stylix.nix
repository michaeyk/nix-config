{pkgs, lib, config, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    
    # Use the same wallpaper as home-manager stylix config
    image = ../../home/programs/stylix-wallpaper.jpeg;
    
    # Use the same base16 scheme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    
    # Configure polarity (dark/light theme)
    polarity = "dark";
    
    # Font configuration (same as home-manager config)
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
  };
}
