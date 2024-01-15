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
      # advanced = {
      #   network_key = "GENERATE";
      # };
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
