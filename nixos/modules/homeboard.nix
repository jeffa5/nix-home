{configs}: {
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.homeboard;

  formatNode = nodeConfig: let
    name = nodeConfig.networking.hostName;
    url = "http://${name}.home.jeffas.net";
  in ''<a href="${url}">${name}</a>'';

  formatService = name: service: let
    url =
      if service.serverName == null
      then ""
      else "http://${service.serverName}";
  in ''<li><a href="${url}">${name}</a></li>'';

  servicesForNode = nodeConfig: let
    nginxHosts = nodeConfig.services.nginx.virtualHosts;
  in
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: formatService name value) nginxHosts);

  links = lib.concatStringsSep "\n" (lib.mapAttrsToList (_name: value: let
      node = formatNode value.config;
      services = servicesForNode value.config;
    in ''
      <h2>${node}</h2>
      <table>
      ${services}
      </table>
    '')
    configs);

  root = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Homeboard</title>
      <style>
        html { color-scheme: light dark; }
        body { width: 35em; margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif; }
        img { vertical-align: middle; }
      </style>
    </head>
    <body>
      <h1>Homeboard</h1>
      ${links}
    </body>
    </html>
  '';
in {
  imports = [];

  options.services.homeboard = {
    enable = lib.mkEnableOption "homeboard service";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."Homeboard" = {
      serverName = "home.jeffas.net";
      root = root;
      forceSSL = true;
      useACMEHost = "home.jeffas.net";
    };
  };
}
