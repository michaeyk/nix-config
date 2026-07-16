{...}: {
  xdg.configFile."herdr/config.toml" = {
    force = true;
    text = ''
      onboarding = false

      [theme]
      name = "kanagawa"
      auto_switch = false

      [keys]
      # Move through Herdr's detected agent panes without leaving prefix mode.
      previous_agent = "prefix+shift+k"
      next_agent = "prefix+shift+j"
      focus_agent = "prefix+alt+1..9"

      [ui.toast]
      delivery = "system"
    '';
  };
}
