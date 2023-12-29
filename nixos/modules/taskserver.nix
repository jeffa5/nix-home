{...}: let
  public_port = 53589;
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
  #   serverName = "${config.networking.hostName}:${toString public_port}";
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
