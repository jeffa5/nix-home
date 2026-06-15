{...}: let
  serverName = "miniflux.home.jeffas.net";
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/etc/miniflux/admin-credentials";
    config = {
      BASE_URL = "https://${serverName}";
    };
  };

  services.nginx.virtualHosts."Miniflux" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
