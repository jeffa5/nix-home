{...}: let
  private_port = 10222;
in {
  services.taskchampion-sync-server = {
    enable = true;
    snapshot.days = 7;
    port = private_port;
  };

  services.nginx.virtualHosts."Task Server" = {
    serverName = "taskserver.home.jeffas.net";
    locations."/" = {
      proxyPass = "https://127.0.0.1:${toString private_port}";
    };
  };
}
