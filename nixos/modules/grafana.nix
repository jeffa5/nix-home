{pkgs, ...}: let
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
        root_url = "https://${serverName}";
      };
      database = {
        type = "postgres";
        host = "/run/postgresql";
        name = "grafana";
        user = "grafana";
      };
      # Disable Grafana's built-in login, use Authelia instead
      auth = {
        disable_login_form = true;
      };
      "auth.anonymous" = {
        enabled = false;
      };
      # Configure auth proxy to trust Authelia headers
      "auth.proxy" = {
        enabled = true;
        header_name = "Remote-User";
        header_property = "username";
        auto_sign_up = true;
        enable_login_token = false;
        headers = "Email:Remote-Email Name:Remote-Name";
      };
      security = {
        secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          url = "https://prometheus.home.jeffas.net";
          type = "prometheus";
        }
        {
          name = "Loki";
          url = "https://loki.home.jeffas.net";
          type = "loki";
        }
        {
          name = "InfluxDB";
          url = "https://influxdb.home.jeffas.net";
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
          name = "restic-loki";
          options.path = ./grafana/dashboard-restic-loki.json;
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

  services.postgresql = {
    ensureDatabases = ["grafana"];
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.grafana = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  services.nginx.virtualHosts."Grafana" = let
    authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  in {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
      extraConfig = ''
        include ${authelia-snippets.proxy};
        include ${authelia-snippets.authelia-authrequest};
      '';
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.authelia-location};
    '';
  };
}
