{config, ...}: {
  services.immich = {
    enable = true;
    port = 2283;
    environment = {
      IMMICH_TELEMETRY_INCLUDE = "all";
    };
  };

  services.nginx.virtualHosts."Immich" = {
    serverName = "immich.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
