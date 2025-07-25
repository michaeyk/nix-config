{pkgs, ...}: {
  networking.wg-quick.interfaces = let
    server_ip = "dellbro00.pimpchoko.com";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.253.0.6/32"
      ];

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [
        {
          publicKey = "FjqISjUvlqYIjYxWHO4K4RNfo+O//qaGiOEInXzJjBY=";
          allowedIPs = ["10.253.0.1/32" "172.16.0.142/32"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };

    # linode to access Augusta
    wg1 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.10.0.5/32"
      ];

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [
        {
          publicKey = "ro+c6m1V+p5tLioNdPiIQsPrVn0DOsydJmdu83ljG1E=";
          allowedIPs = ["10.10.0.0/24"];
          endpoint = "172.235.56.182:51820";
          persistentKeepalive = 25;
        }
      ];
    };

    # ai-workstation
    wg2 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.8.0.9/32"
      ];

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [
        {
          publicKey = "Uj/Mnp8xqpnLMRUAwexG1p2PF8CKLz4K6MhOOqscBxE=";
          allowedIPs = ["10.8.0.1/32" "172.16.0.135/32"];
          endpoint = "${server_ip}:52820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
