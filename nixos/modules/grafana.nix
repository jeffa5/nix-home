{...}: let
  ports = import ./ports.nix;
  private_port = ports.grafana.private;
  serverName = "grafana.home.jeffas.net";
  influxdbAdminToken = "admintoken";
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
        {
          name = "InfluxDB";
          url = "http://influxdb.home.jeffas.net";
          type = "influxdb";
          jsonData = {
            httpHeaderName1 = "Authorization";
          };
          secureJsonData = {
            httpHeaderValue1 = "Token ${influxdbAdminToken}";
          };
          database = "zigbee";
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
        {
          type = "file";
          name = "sensors";
          options.path = ./grafana/dashboard-sensors.json;
        }
        {
          type = "file";
          name = "loki";
          options.path = ./grafana/dashboard-loki.json;
        }
        {
          type = "file";
          name = "dnsmasq";
          options.path = ./grafana/dashboard-dnsmasq.json;
        }
        {
          type = "file";
          name = "restic";
          options.path = ./grafana/dashboard-restic.json;
        }
        {
          type = "file";
          name = "postgres";
          options.path = ./grafana/dashboard-postgres.json;
        }
      ];
    };
  };

  services.nginx.virtualHosts."Grafana" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
