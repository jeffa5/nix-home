{pkgs, ...}: let
  port = 5232;
in {
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [
        "127.0.0.1:${toString port}"
      ];
      storage.filesystem_folder = "/var/lib/radicale/collections";
      auth = {
        # type = "http_remote_user";
        type = "http_x_remote_user";
      };
    };
  };

  services.nginx.virtualHosts."Radicale" = let
    authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  in {
    serverName = "dav.home.jeffas.net";
    locations."/.web/" = {
      proxyPass = "http://127.0.0.1:${toString port}/$request_uri";
      extraConfig = ''
        include ${authelia-snippets.proxy};
        include ${authelia-snippets.authelia-authrequest};
      '';
    };
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
      extraConfig = ''
        include ${authelia-snippets.proxy};
        include ${authelia-snippets.authelia-authrequest-basic};
      '';
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.authelia-location-basic};
      include ${authelia-snippets.authelia-location};
    '';
  };
}
