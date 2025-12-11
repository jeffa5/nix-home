{pkgs, ...}: {
  services.nginx.virtualHosts."Files" = let
    authelia-snippets = import ../modules/authelia-snippets.nix {inherit pkgs;};
  in {
    serverName = "files.home.jeffas.net";
    root = "/local/files/";
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      autoindex on;
      include ${authelia-snippets.proxy};
      include ${authelia-snippets.authelia-authrequest};
      include ${authelia-snippets.authelia-location};
    '';
  };
}
