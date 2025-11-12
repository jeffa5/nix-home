{
  config,
  pkgs,
  ...
}: let
  authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  serverName = "paperless.home.jeffas.net";
in {
  environment.etc."paperless/admin-pass".text = "admin";
  services.paperless = {
    enable = true;
    passwordFile = "/etc/paperless/admin-pass";
    database.createLocally = true;
    settings = {
      PAPERLESS_URL = "https://${serverName}";
      PAPERLESS_CONSUMER_RECURSIVE = true;
    };
  };

  services.nginx.virtualHosts."Paperless" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
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
