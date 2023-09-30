{config, ...}: let
  public_port = 3000;
  private_port = 3001;
in {
  services.grafana = {
    enable = true;
    settings.server = {
      http_port = private_port;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          type = "prometheus";
        }
      ];
    };
  };

  services.nginx.virtualHosts."grafana.local" = {
    # TODO: use DNS for this rather than relying on the ip
    serverName = "192.168.0.52:${toString public_port}";
    listen = [
      {
        port = public_port;
        addr = "0.0.0.0";
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };

  # TODO: specify default openings for nginx once we have DNS names
  networking.firewall.allowedTCPPorts = [public_port];
}
