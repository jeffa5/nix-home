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
        "0x00158d000ab75716" = {
          friendly_name = "boiler/vibration";
        };
        "0xa4c1380101c477a3" = {
          friendly_name = "desk/homelab/power";
        };
        "0xa4c1384f889e5eed" = {
          friendly_name = "desk/charger/power";
        };
        "0xa4c13890038bb6fc" = {
          friendly_name = "desk/router/power";
        };
        "0xa4c1384d69014eec" = {
          friendly_name = "kitchen/ap/power";
        };
      };
    };
  };

  # wait for storage
  systemd.services.zigbee2mqtt = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };

  services.nginx.virtualHosts."Zigbee2MQTT" = {
    serverName = "zigbee2mqtt.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
