{pkgs, ...}: let
  serverName = "zigbee2mqtt.home.jeffas.net";
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
        enable = true;
        port = port;
        url = "https://${serverName}";
      };
      advanced = {
        last_seen = "ISO_8601";
        #   network_key = "GENERATE";
      };
      homeassistant = {
        enabled = true;
      };

      devices = {
        "0x00158d000ab704e1" = {
          friendly_name = "kitchen/washing_machine/vibration";
          homeassistant = {
            name = "Kitchen vibration sensor";
            device = {
              suggested_area = "kitchen";
            };
          };
        };
        "0x9035eafffe0d82b3" = {
          friendly_name = "bedroom/temp_hum";
          homeassistant = {
            name = "Bedroom temperature sensor";
            device = {
              suggested_area = "bedroom";
            };
          };
        };
        "0x9035eafffe02bb4c" = {
          friendly_name = "lounge/temp_hum";
          homeassistant = {
            name = "Lounge temperature sensor";
            device = {
              suggested_area = "lounge";
            };
          };
        };
        "0x9035eafffe02b57c" = {
          friendly_name = "kitchen/temp_hum";
          homeassistant = {
            name = "Kitchen temperature sensor";
            device = {
              suggested_area = "kitchen";
            };
          };
        };
        "0xa4c1380101c477a3" = {
          friendly_name = "desk/homelab/power";
          homeassistant = {
            name = "Desk homelab plug";
            device = {
              suggested_area = "desk";
            };
          };
        };
        "0xa4c1384f889e5eed" = {
          friendly_name = "kitchen/fridge/power";
          homeassistant = {
            name = "Kitchen fridge plug";
            device = {
              suggested_area = "kitchen";
            };
          };
        };
        "0xa4c13890038bb6fc" = {
          friendly_name = "lounge/bookshelf_lamp/power";
          homeassistant = {
            name = "Lounge bookshelf lamp power";
            device = {
              suggested_area = "lounge";
            };
          };
        };
        "0xa4c1384d69014eec" = {
          friendly_name = "lounge/xmas_lights/power";
          homeassistant = {
            name = "Lounge xmas lights plug";
            device = {
              suggested_area = "lounge";
            };
          };
        };
        "0xa4c138369a7c7618" = {
          friendly_name = "bedroom/bedside_left/light";
          homeassistant = {
            name = "Bedside lamp - left";
            device = {
              suggested_area = "bedroom";
            };
          };
        };
        "0xa4c1383784ccb9df" = {
          friendly_name = "bedroom/bedside_right/light";
          homeassistant = {
            name = "Bedside lamp - right";
            device = {
              suggested_area = "bedroom";
            };
          };
        };
        "0x943469fffe3dfcc0" = {
          friendly_name = "bedroom/mobile/switch";
          homeassistant = {
            name = "Bedside lamp switch";
            device = {
              suggested_area = "bedroom";
            };
          };
        };
        "0x943469fffe3de99a" = {
          friendly_name = "lounge/mobile/switch";
          homeassistant = {
            name = "Lounge lamp switch";
            device = {
              suggested_area = "lounge";
            };
          };
        };
        "0xa4c1389ff9ea695d" = {
          friendly_name = "lounge/reading_chair/light";
          homeassistant = {
            name = "Lounge reading chair lamp";
            device = {
              suggested_area = "lounge";
            };
          };
        };
        "0xa4c138bceb19acb1" = {
          friendly_name = "bedroom/corner/light";
          homeassistant = {
            name = "Bedroom corner lamp";
            device = {
              suggested_area = "bedroom";
            };
          };
        };
      };

      groups = {
        "1" = {
          friendly_name = "Bedroom lights";
          transition = 2;
          devices = [
            "0xa4c138369a7c7618"
            "0xa4c1383784ccb9df"
            "0xa4c1384d69014eec"
          ];
        };
      };
    };
  };

  # wait for storage
  systemd.services.zigbee2mqtt = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };

  services.nginx.virtualHosts."Zigbee2MQTT" = let
    authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  in {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
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
