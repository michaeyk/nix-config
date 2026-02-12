# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, inputs, pkgs, ... }:

let
  yubikey-gpg-refresh = pkgs.writeShellScript "yubikey-gpg-refresh-udev" ''
    export XDG_RUNTIME_DIR=/run/user/1000

    # Wait for YubiKey USB device to appear (vendor 1050 = Yubico)
    for i in $(seq 1 30); do
      if ${pkgs.coreutils}/bin/ls /sys/bus/usb/devices/*/idVendor 2>/dev/null | \
         ${pkgs.findutils}/bin/xargs -I{} ${pkgs.coreutils}/bin/cat {} 2>/dev/null | \
         ${pkgs.gnugrep}/bin/grep -q "1050"; then
        break
      fi
      sleep 0.5
    done

    # Kill all GPG daemons to clear stale state (gpg-agent caches card info)
    ${pkgs.util-linux}/bin/runuser -u mike -- ${pkgs.gnupg}/bin/gpgconf --kill all

    # Restart pcscd to ensure it re-detects the reader after suspend
    ${pkgs.systemd}/bin/systemctl restart pcscd.service
    sleep 1

    # Verify card is accessible (with retry)
    for i in $(seq 1 10); do
      if ${pkgs.util-linux}/bin/runuser -u mike -- ${pkgs.gnupg}/bin/gpg --card-status &>/dev/null; then
        exit 0
      fi
      sleep 0.5
    done
  '';
in {
  imports =
    [ # Include the results of the hardware scan.
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

    ANTHROPIC_API_KEY = {
      owner = config.users.users.mike.name;
    };

    "yubico/u2f_keys" = {
      owner = config.users.users.mike.name;
      inherit (config.users.users.mike) group;
      path = "/home/mike/.config/Yubico/u2f_keys";
    };

    "coinmarketcap_api" = {
      owner = config.users.users.mike.name;
      mode = "0400";
    };

    "nextcloud" = {
      owner = "root";
      path = "/etc/davfs2/secrets";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gaming"; # Define your hostname.

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

   # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Required for proper suspend/resume.
    # Saves VRAM to disk before suspend and restores it on wake.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.production; # Latest production driver
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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    foomatic-db-ppds-withNonfreeDb
    splix
  ];

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
    openFirewall = true;
  };

  # Enable nix-ld for running non-NixOS binaries (e.g., Dell printer driver)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      cups
    ];
  };

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

  # FUSE mount filesystem on /bin for $PATH
  services.envfs.enable = true;

  # Ledger Nano X
  hardware.ledger.enable = true;

  # yubikey and ledger live udev rules
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
  services.udev.extraRules = ''
    # Refresh GPG stubs when YubiKey is inserted
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1050", RUN+="${yubikey-gpg-refresh}"

    # Allow input group to create virtual gamepads (for Sunshine)
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input"
  '';

  security = {
    polkit.enable = true;
    sudo.extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
    pam = {
      sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = ["%h/.ssh/authorized_keys"];
      };
      u2f = {
        enable = true;
        settings = {
          # interactive = true;
          cue = true;
          pinAuth = true;
          authFile = "/home/mike/.config/Yubico/u2f_keys";
        };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = false;
          sshAgentAuth = true;
        };
        hyprlock.u2fAuth = true;
      };
    };
  };

  # Groups
  users.groups.plugdev = {};
  users.groups.davfs2 = {};

  # System users
  users.users.davfs2 = {
    isSystemUser = true;
    group = "davfs2";
    description = "davfs2 system user";
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.mike = {
    isNormalUser = true;
    description = "Michael Kim";
    extraGroups = ["networkmanager" "wheel" "plugdev" "davfs2" "video" "render" "input"];
  };

  programs.git.enable = true;

  programs.hyprland = {
    enable = true;
  };

  # NVIDIA suspend fix: pause Hyprland before GPU suspends to prevent crash
  systemd.services.hyprland-suspend = {
    description = "Suspend Hyprland before sleep";
    before = [ "systemd-suspend.service" "nvidia-suspend.service" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.procps}/bin/pkill -STOP Hyprland";
    };
  };

  systemd.services.hyprland-resume = {
    description = "Resume Hyprland after sleep";
    after = [ "systemd-resume.service" "nvidia-resume.service" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${pkgs.procps}/bin/pkill -CONT Hyprland";
    };
  };

  # Restart NetworkManager after resume to restore connectivity
  systemd.services.network-resume = {
    description = "Restart NetworkManager after sleep";
    after = [ "systemd-resume.service" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart NetworkManager.service";
    };
  };

  # Restart Bluetooth after resume to fix device connection issues
  systemd.services.bluetooth-resume = {
    description = "Restart Bluetooth after sleep";
    after = [ "systemd-resume.service" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart bluetooth.service";
    };
  };

  # Reset GPG after resume so YubiKey is recognized
  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/runuser -u mike -- ${pkgs.gnupg}/bin/gpgconf --kill all
    ${pkgs.systemd}/bin/systemctl restart pcscd.service
  '';

  programs.seahorse.enable = true;

  programs.ssh.startAgent = false; # gpg-agent instead
  programs.yubikey-touch-detector = {
    enable = true;
    libnotify = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Sunshine game streaming server (for Moonlight clients)
  services.sunshine = {
    enable = true;
    autoStart = false; # Don't run as system service - needs user session for Wayland
    capSysAdmin = true; # Required for KMS capture on Wayland
    openFirewall = true;
  };

  # Flatpak
  services.flatpak.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # experimental
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.settings.download-buffer-size = 524288000;

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
    mesa-demos
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
    yubikey-manager
    pam_u2f
    davfs2
    ethtool
  ];

  # Wake-on-LAN: enable magic packet wake on ethernet interface
  systemd.services.wol-enable = {
    description = "Enable Wake-on-LAN on enp4s0";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp4s0 wol g";
      RemainAfterExit = true;
    };
  };

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

