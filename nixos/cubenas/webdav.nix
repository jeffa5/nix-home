{pkgs, ...}: let
  authelia-snippets = import ../modules/authelia-snippets.nix {inherit pkgs;};
  davRoot = "/local/files";
in {
  services.nginx.virtualHosts."WebDAV" = {
    serverName = "dav.home.jeffas.net";
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.authelia-location-basic};
    '';
    locations."/" = {
      root = davRoot;
      extraConfig = ''
        include ${authelia-snippets.authelia-authrequest-basic};

        dav_methods PUT DELETE MKCOL COPY MOVE;
        dav_ext_methods PROPFIND OPTIONS;
        dav_access user:rw group:rw;
        create_full_put_path on;
        client_max_body_size 0;

        autoindex on;

        auth_request_set $www_authenticate $upstream_http_www_authenticate;
        add_header WWW-Authenticate $www_authenticate always;
      '';
    };
  };

  users.users.nginx.extraGroups = ["family" "andrew-files" "charlene-files"];
}
