{pkgs, ...}: let
  authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  serverName = "filebrowser.home.jeffas.net";
  port = 8484;
in {
  # Override the filebrowser module's tmpfiles rule which would chown /local/files
  # to filebrowser:filebrowser:0700. File sorting ensures this wins (00- < filebrowser).
  systemd.tmpfiles.settings."00-local-files"."/local/files".d = {
    user = "root";
    group = "users";
    mode = "0755";
  };

  services.filebrowser = {
    enable = true;
    user = "filebrowser";
    settings = {
      address = "127.0.0.1";
      inherit port;
      root = "/local/files";
    };
  };

  users.users.filebrowser.extraGroups = ["family" "andrew-files" "charlene-files"];

  services.nginx.virtualHosts."Filebrowser" = {
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
