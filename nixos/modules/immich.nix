{config, ...}: {
  services.immich.enable = true;
  services.immich.port = 2283;

  services.nginx.virtualHosts."Immich" = {
    serverName = "photos.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
      proxyWebsockets = true;
    };
  };
}
