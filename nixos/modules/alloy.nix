{
  config,
  pkgs,
  ...
}: let
  loki_address = "loki.home.jeffas.net";
  ports = import ./ports.nix;
  alloyConfig = pkgs.writeText "config.alloy" ''
    loki.source.journal "journal" {
      max_age = "12h"
      labels = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
      relabel_rules = loki.relabel.journal.rules
      forward_to    = [loki.write.default.receiver]
    }

    loki.relabel "journal" {
      forward_to = []
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.write "default" {
      endpoint {
        url = "https://${loki_address}/loki/api/v1/push"
      }
    }
  '';
in {
  services.alloy = {
    enable = true;
    configPath = alloyConfig;
  };

  services.nginx.virtualHosts."Alloy" = {
    serverName = "alloy.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.alloy.private}";
      proxyWebsockets = true;
    };
  };
}
