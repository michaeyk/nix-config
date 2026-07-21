# Shared login manager: SDDM (Wayland Qt6 greeter) with the sddm-astronaut
# "black_hole" theme.
#
# Imported by hosts that run Hyprland-under-UWSM. Each host sets its own
# `services.displayManager.sddm.wayland.compositor` (kwin on NVIDIA, weston
# elsewhere) — everything else is common and lives here.
#
# Theming note: the home-manager Stylix module can't theme SDDM (it's a system
# service) and this Stylix version ships no `targets.sddm`, so the greeter is
# themed with a standalone SDDM theme package instead of Stylix.
{pkgs, ...}: {
  services.displayManager.sddm = {
    enable = true;
    # Run SDDM's own greeter on Wayland (Qt6) rather than spinning up Xorg.
    wayland.enable = true;

    # sddm-astronaut is a Qt6/QML theme with several bundled looks; select the
    # "black_hole" one via the package's embeddedTheme override. Installing the
    # theme package (below, in systemPackages) is what puts it on SDDM's theme
    # search path; this just points SDDM at it by name.
    theme = "sddm-astronaut-theme";
    # QML runtime deps the astronaut greeter loads at startup (qtsvg,
    # qtmultimedia, qtvirtualkeyboard). Pulled straight from the theme package
    # so they can't drift out of sync with it.
    extraPackages = pkgs.sddm-astronaut.propagatedBuildInputs;
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
  ];

  # Pin the UWSM-managed Hyprland session as the default. SDDM has no ly-style
  # `save = false`, so instead we force the default via NixOS's DefaultSession
  # support (writes `DefaultSession=hyprland-uwsm.desktop` into sddm.conf). This
  # keeps us out of the plain "Hyprland" entry, which would otherwise leave
  # graphical-session.target inactive and hypridle.service dead. The session id
  # is `hyprland-uwsm` (file hyprland-uwsm.desktop, Name "Hyprland (uwsm-managed)").
  services.displayManager.defaultSession = "hyprland-uwsm";
}
