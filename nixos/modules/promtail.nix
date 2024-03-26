{config, ...}: let
  loki_address = "loki.home.jeffas.net";
  ports = import ./ports.nix;
in {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = ports.promtail.private;
        grpc_listen_port = ports.promtail.private_grpc;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://${loki_address}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."Promtail" = {
    serverName = "promtail.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.promtail.private}";
      proxyWebsockets = true;
    };
  };
}
