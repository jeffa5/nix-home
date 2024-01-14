{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.nodeboard;

  nginxHosts = config.services.nginx.virtualHosts;

  formatService = name: service: let
    url =
      if service.serverName == null
      then ""
      else "http://${service.serverName}";
  in ''<li><a href="${url}">${name}</a></li>'';
  services = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: formatService name value) nginxHosts);

  root = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Nodeboard</title>
      <style>
        html { color-scheme: light dark; }
        body { width: 35em; margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif; }
        img { vertical-align: middle; }
      </style>
    </head>
    <body>
      <h1>Nodeboard</h1>
      <ul>
        ${services}
      </ul>
    </body>
    </html>
  '';
in {
  imports = [];

  options.services.nodeboard = {
    enable = lib.mkEnableOption "nodeboard service";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."nodeboard.local" = {
      serverName = "${config.networking.hostName}.home.jeffas.net";
      root = root;
      default = true;
    };
  };
}
