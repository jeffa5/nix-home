{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [pkgs.immich-cli];

  services.immich = {
    enable = true;
    port = 2283;
    environment = {
      IMMICH_TELEMETRY_INCLUDE = "all";
    };
    settings = {
      library.watch.enabled = true;
      oauth = {
        enabled = true;
        issuerUrl = "https://authelia.home.jeffas.net";
        clientId = "immich";
        clientSecret._secret = "/etc/immich/oauthClientSecret";
        autoRegister = true;
        buttonText = "Login with Authelia";
        autoLaunch = false;
      };
    };
  };

  users.users.immich.extraGroups = ["andrew-files" "charlene-files"];

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
