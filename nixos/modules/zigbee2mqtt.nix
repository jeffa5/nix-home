{...}: let
  port = 9070;
in {
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;
      mqtt = {
        server = "mqtt://127.0.0.1:1883";
      };
      serial = {
        port = "/dev/ttyUSB0";
      };
      frontend = {
        port = port;
      };
      advanced = {
        last_seen = "ISO_8601";
        #   network_key = "GENERATE";
      };

      devices = {
        "0x9035eafffe0d82b3" = {
          friendly_name = "bedroom/temp_hum";
        };
        "0x9035eafffe02bb4c" = {
          friendly_name = "desk/temp_hum";
        };
        "0x9035eafffe02b57c" = {
          friendly_name = "kitchen/temp_hum";
        };
      };
    };
  };

  services.nginx.virtualHosts."Zigbee2MQTT" = {
    serverName = "zigbee2mqtt.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
