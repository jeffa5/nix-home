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

  formatService = service: let
    icon =
      if service.icon != ""
      then service.icon
      else if service.useFavicon
      then "${service.url}/favicon.ico"
      else "";
    iconImg =
      if icon != ""
      then ''<img src="${icon}" width=50 height=50></img>''
      else "";
  in ''<tr><td>${iconImg}</td><td><a href="${service.url}">${service.name}</a></td></tr>'';
  servicesForNode = nodeConfig: let
    nodeboard = nodeConfig.services.nodeboard;
  in
    lib.concatStringsSep "\n" (lib.mapAttrsToList (_name: value: formatService value) (nodeboard.services));

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
    services.nginx.virtualHosts."homeboard.local" = {
      serverName = "home.jeffas.net";
      root = root;
    };
  };
}
