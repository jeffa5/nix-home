{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.nodeboard;

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
  services = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: formatService value) (cfg.services));

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
      <table>
        ${services}
      </table>
    </body>
    </html>
  '';
in {
  imports = [];

  options.services.nodeboard = {
    enable = lib.mkEnableOption "nodeboard service";
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          url = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          icon = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          useFavicon = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      });
      example = {
        grafana = {
          name = "Grafana";
          url = "http://grafana.local:3000";
          icon = "http://grafana.local:3000/favicon.ico";
          useFavicon = false;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."nodeboard.local" = {
      serverName = "${config.networking.hostName}:${toString 80}";
      listen = [
        {
          port = 80;
          addr = "0.0.0.0";
        }
      ];
      root = root;
      default = true;
    };

    # TODO: specify default openings for nginx once we have DNS names
    networking.firewall.allowedTCPPorts = [80];
  };
}
