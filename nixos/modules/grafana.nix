{...}: let
  ports = import ./ports.nix;
  private_port = ports.grafana.private;
  serverName = "grafana.home.jeffas.net";
in {
  services.grafana = {
    enable = true;
    settings = {
      users = {
        default_theme = "system";
      };
      server = {
        http_port = private_port;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          url = "http://prometheus.home.jeffas.net";
          type = "prometheus";
        }
        {
          name = "Loki";
          url = "http://loki.home.jeffas.net";
          type = "loki";
        }
      ];

      dashboards.settings.providers = [
        {
          type = "file";
          name = "node";
          options.path = ./grafana/dashboard-node.json;
        }
        {
          type = "file";
          name = "nginx";
          options.path = ./grafana/dashboard-nginx.json;
        }
        {
          type = "file";
          name = "battery";
          options.path = ./grafana/dashboard-battery.json;
        }
      ];
    };
  };

  services.nodeboard.services.grafana = {
    name = "Grafana";
    url = "http://${serverName}";
    icon = "http://${serverName}/public/img/apple-touch-icon.png";
  };

  services.nginx.virtualHosts."grafana.local" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };
}
