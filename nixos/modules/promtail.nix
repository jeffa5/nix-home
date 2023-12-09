{openFirewall}: {
  pkgs,
  config,
  ...
}: let
  loki_address = "100.85.109.140";
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
          url = "http://${loki_address}:${toString ports.loki.public}/loki/api/v1/push";
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

  services.nodeboard.services.promtail = {
    name = "Promtail";
    url = "http://${config.networking.hostName}:${toString ports.promtail.public}";
  };

  services.nginx.virtualHosts."promtail.local" = {
    serverName = "${config.networking.hostName}:${toString ports.promtail.public}";
    listen = [
      {
        port = ports.promtail.public;
        addr = "0.0.0.0";
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.promtail.private}";
      proxyWebsockets = true;
    };
  };

  # TODO: specify default openings for nginx once we have DNS names
  networking.firewall.allowedTCPPorts = pkgs.lib.optionals openFirewall [ports.promtail.public];
}
