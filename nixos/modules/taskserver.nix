{...}: let
  public_port = 53589;
  private_port = 53588;
in {
  services.taskserver = {
    enable = true;
    listenPort = public_port;
    fqdn = "100.85.109.140";
    debug = true;
    organisations = {
      jeffas = {
        users = ["andrew"];
      };
    };
    openFirewall = true;
    listenHost = "0.0.0.0";
  };

  # services.nginx.virtualHosts."taskserver.local" = {
  #   # TODO: use DNS for this rather than relying on the ip
  #   serverName = "192.168.0.52:${toString public_port}";
  #   listen = [
  #     {
  #       port = public_port;
  #       addr = "0.0.0.0";
  #     }
  #   ];
  #   locations."/" = {
  #     proxyPass = "https://127.0.0.1:${toString private_port}";
  #   };
  # };
  #
  # # TODO: specify default openings for nginx once we have DNS names
  # networking.firewall.allowedTCPPorts = [public_port];
}
