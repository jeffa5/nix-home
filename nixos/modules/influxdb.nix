{...}: let
  # ports = import ./ports.nix;
  port = 8086;
  adminPassword = "adminadmin";
  adminToken = "admintoken";
in {
  services.influxdb2 = {
    enable = true;
    settings = {
      # http-bind-address = ":${toString port}";
      reporting-disabled = true;
    };
    provision = {
      enable = true;
      initialSetup = {
        username = "admin";
        organization = "Home";
        bucket = "zigbee";
        passwordFile = builtins.toFile "influxpasswd" adminPassword;
        tokenFile = builtins.toFile "influxtoken" adminToken;
      };
    };
  };

  services.telegraf = {
    enable = true;
    extraConfig = {
      # https://gist.github.com/geekman/9272f3edb41b1692b74c130bf25734b3
      inputs = {
        mqtt_consumer = [
          {
            servers = ["tcp://127.0.0.1:1883"];
            topics = ["zigbee2mqtt/#"];
            data_format = "json";
            topic_tag = "device";
            name_override = "zigbee";
            tagdrop = {
              device = ["zigbee2mqtt/bridge/*"];
            };
          }
        ];
      };
      processors = {
        regex = [
          {
            namepass = ["zigbee"];
            tags = [
              {
                key = "device";
                pattern = "^zigbee2mqtt/(?P<device>.+)$";
                replacement = "\${device}";
              }
            ];
          }
        ];
      };

      outputs = {
        influxdb_v2 = [
          {
            urls = ["http://localhost:${toString port}"];
            token = adminToken;
            organization = "Home";
            bucket = "zigbee";
          }
        ];
      };
    };
  };

  # # TODO: get prometheus to scrape this
  # services.prometheus.exporters.influxdb = {
  #   enable = true;
  # };

  # wait for storage
  systemd.services.influxdb2 = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };

  services.nginx.virtualHosts."Influxdb" = {
    serverName = "influxdb.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
