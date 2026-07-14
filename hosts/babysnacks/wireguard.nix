{ config, lib, ... }: {
  # WireGuard private key, decrypted by sops-nix to /run/secrets on rebuild.
  sops.secrets."wireguard/babysnacks-wg0-privkey" = { };

  systemd.services = lib.genAttrs ["wg-quick-wg0"] (_: {
    # Bring the tunnel up at boot (wg-quick's default wantedBy is
    # multi-user.target); keep the timeouts short so a rebuild/boot
    # doesn't hang if dellbro00 is unreachable.
    serviceConfig = {
      TimeoutStartSec = "15s";
      TimeoutStopSec = "15s";
    };
  });

  networking.wg-quick.interfaces = let
    server_ip = "dellbro00.pimpchoko.com";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.253.0.3/32"
      ];

      # Path to the private key file (managed by sops-nix).
      privateKeyFile = config.sops.secrets."wireguard/babysnacks-wg0-privkey".path;

      peers = [{
        publicKey = "FjqISjUvlqYIjYxWHO4K4RNfo+O//qaGiOEInXzJjBY=";
        allowedIPs = [ "10.253.0.1/32" "172.16.0.135/32"];
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
