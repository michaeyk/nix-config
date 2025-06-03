# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  sops.defaultSopsFile = ../../home/programs/secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/mike/.config/sops/age/keys.txt";

  sops.secrets = {
    COPILOT_API_KEY = {
      owner = config.users.users.mike.name;
    };

    "yubico/u2f_keys" = {
      owner = config.users.users.mike.name;
      inherit (config.users.users.mike) group;
      path = "/home/mike/.config/Yubico/u2f_keys";
    };

    "nextcloud" = {
      owner = "root";
      path = "/etc/davfs2/secrets";
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    luks.devices."luks-4efe156e-cec3-45bd-80b8-3d6c9635344d" = {
      device = "/dev/disk/by-uuid/4efe156e-cec3-45bd-80b8-3d6c9635344d";
      yubikey.twoFactor = true;
    };
    supportedFilesystems = ["nfs"];
    kernelModules = ["nfs"];
  };

  networking.hostName = "babysnacks"; # Define your hostname.

  environment.shells = with pkgs; [zsh bash];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.power-profiles-daemon.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.gutenprint];

  services.printing.browsing = true;
  services.printing.browsedConf = ''
    BrowseDNSSDSubTypes _cups,_print
    BrowseLocalProtocols all
    BrowseRemoteProtocols all
    CreateIPPPrinterQueues All

    BrowseProtocols all
  '';
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.fprintd.enable = true;

  services.fwupd.enable = true;
  # we need fwupd 1.9.7 to downgrade the fingerprint sensor firmware
  services.fwupd.package =
    (import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
        sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
      }) {
        inherit (pkgs) system;
      })
    .fwupd;

  # Enable boltd for thunderbolt
  services.hardware.bolt.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.steam-hardware.enable = true;

  services.blueman.enable = true;

  services.libinput.enable = true;

  services.upower.enable = true;

  services.pcscd.enable = true;

  # FUSE mount filesystem on /bin for $PATH
  services.envfs.enable = true;

  # Ledger Nano X
  hardware.ledger.enable = true;

  # yubikey and ledger live udev rules
  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
    ];
  };

  security = {
    polkit.enable = true;
    pam = {
      sshAgentAuth.enable = true;
      u2f = {
        enable = true;
        settings = {
          # interactive = true;
          cue = true;
          authFile = "/home/mike/.config/Yubico/u2f_keys";
        };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
        hyprlock = {};
      };
    };
  };

  # Groups
  users.groups.plugdev = {};
  users.groups.davfs2 = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mike = {
    isNormalUser = true;
    description = "Michael Kim";
    extraGroups = ["networkmanager" "wheel" "plugdev" "davfs2"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.git.enable = true;

  programs.hyprland = {
    enable = true;
  };

  programs.seahorse.enable = true;

  programs.ssh.startAgent = false; # gpg-agent instead
  programs.yubikey-touch-detector.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # experimental
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.extraOptions = ''
    trusted-users = root mike
  '';

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    lshw
    bolt
    glxinfo
    nfs-utils
    wireguard-tools
    gutenprint
    gutenprintBin
    libnotify
    nixd
    devenv
    yubioath-flutter
    yubikey-touch-detector
    yubikey-personalization
    yubikey-personalization-gui
    yubikey-manager
    pam_u2f
    davfs2
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  fileSystems = {
    "/mnt/mike" = {
      device = "10.253.0.1:/mnt/user/mike";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
    };

    "/mnt/nextcloud" = {
      device = "https://nextcloud.michaelkim.net/remote.php/dav/files/mike";
      fsType = "davfs";
      options = ["uid=1000" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [51820];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
