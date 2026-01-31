{
  pkgs,
  config,
  ...
}: {
  services.home-assistant = {
    enable = true;
    extraPackages = ps: [
      ps.psycopg2 # for postgresql
    ];
    extraComponents = [
      "default_config"
      "esphome"
      "google_translate"
      "isal"
      "met"
      "mobile_app"
      "mqtt"
      "radio_browser"
      "shopping_list"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      recorder.db_url = "postgresql://@/hass";
      http = {
        server_host = "127.0.0.1";
        trusted_proxies = ["127.0.0.1"];
        use_x_forwarded_for = true;
      };

      "automation ui" = "!include automations.yaml";
      # "scene ui" = "!include scenes.yaml";
      # "script ui" = "!include scripts.yaml";
    };
  };

  services.postgresql = {
    ensureDatabases = ["hass"];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.virtualHosts."Home Assistant" = let
    authelia-snippets = import ../modules/authelia-snippets.nix {inherit pkgs;};
  in {
    serverName = "hass.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
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
