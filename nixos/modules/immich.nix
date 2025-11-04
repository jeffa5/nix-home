{config, ...}: {
  services.immich.enable = true;
  services.immich.port = 2283;

  services.nginx.virtualHosts."Immich" = {
    serverName = "photos.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
