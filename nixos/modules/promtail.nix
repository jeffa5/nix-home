{config, ...}: let
  loki_address = "100.85.109.140";
  ports = import ./ports.nix;
in {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        disable = true;
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
}
