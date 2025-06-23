{ pkgs, ... }: {
  networking.wg-quick.interfaces = let
    server_ip = "dellbro00.pimpchoko.com";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.253.0.5/32"
      ];

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [{
        publicKey = "FjqISjUvlqYIjYxWHO4K4RNfo+O//qaGiOEInXzJjBY=";
        allowedIPs = [ "10.253.0.1/32" "172.16.0.142/32"];
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };

    # ai-workstation
    wg1 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.8.0.2/32"
      ];

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [{
        publicKey = "Uj/Mnp8xqpnLMRUAwexG1p2PF8CKLz4K6MhOOqscBxE=";
        allowedIPs = [ "10.8.0.1/32" "172.16.0.135/32"];
        endpoint = "${server_ip}:52820";
        persistentKeepalive = 25;
      }];
    };
  };
}
