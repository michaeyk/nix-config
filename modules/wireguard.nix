{ pkgs, ... }: {
  networking.wg-quick.interfaces = let
    server_ip = "dellbro00.pimpchoko.com";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.253.0.5/32"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/home/mike/.wireguard/private-key";

      peers = [{
        publicKey = "FjqISjUvlqYIjYxWHO4K4RNfo+O//qaGiOEInXzJjBY=";
        allowedIPs = [ "10.253.0.1/32" "172.16.0.142/32"];
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
