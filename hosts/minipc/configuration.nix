{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "minipc";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.shells = with pkgs; [zsh bash];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  users.users.mike = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "docker"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvSJEnrQzShyzVPuMmX+ES+7NNfAjkQW9bMClMG1dATHBb+snYyKBT1YOlElxRHfs1IQAk8kqMZyV8MJhIpG1gEN9vkl6PHr6m0wuxzIIqsu3z7p2UBCLzJH27lR+1gKYtZwJXSg3hmBqMI8EpoTgVG06OeNc94Pn73sBi5/ENKZ4wieqrkt1HAVlpyj5fgONFXXfF9/iUjU3B7U2j53l4wTje8T2UW49qE8nGvPSG9myLnfP545kCtwqIugZcxOUW4UI+ThG0g2+icyUiSbq8cIfuEucb/HSulznCWy3DoF8um58NIt65+zYpZqols/q91CKo+Qs/mNRP63wPnQ2wYy0sqhaZ8DIVX7EMDG4gH5hhyju+hVfXiacVK8QxeK19N9LJ5FZC6uVtFtZ0a3k3pcNPIrx/k1ZlnxBPnbidur3Jupm9pCHG+2cYT/lO13pgNN3va3RIOoRd5h1Zb831qU056ZHyTV+Xf83bHIZ4CuJvRIbwsfe+1wtSIlwdqjVy2m3V5CYn1T2Ov/2AS9/3sYutJGmDqu7S35PqiXxMu4AR5GJSd05Iro20+qppIFiN4sc6O9QAdA+Kbm+0RBzaJINBCQPFvKGgtaj1G8NdE+ftSMbIRSG+WotLlv7TJTJ6c3Qm3OTJ30YiZ1HYr6A/vo1lai0ob55kdGUtQgZOeQ== cardno:20_499_022"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    htop
    docker-compose
  ];

  # Set this to the NixOS release the box was first installed with, then
  # leave it alone (see `man configuration.nix` for the stateVersion comment).
  system.stateVersion = "25.05";
}
