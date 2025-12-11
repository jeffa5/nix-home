{...}: let
  wwwPort = 3080;
  gitPort = 3081;
  pagesPort = 3082;

  wwwLocal = "localhost:${toString wwwPort}";
  gitLocal = "localhost:${toString gitPort}";
  pagesLocal = "localhost:${toString pagesPort}";

  mkNginxConf = {
    serverName,
    root,
    port,
  }: {
    inherit serverName;
    extraConfig = ''
      server_name_in_redirect on;
      port_in_redirect off;
    '';
    locations."/" = {
      inherit root;
    };
    listen = [
      {
        inherit port;
        addr = "127.0.0.1";
      }
    ];
  };
in {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "bb0853ce-9799-4f0f-9b0d-80250eae1002" = {
        credentialsFile = "/local/cloudflared/bb0853ce-9799-4f0f-9b0d-80250eae1002.json";
        default = "http_status:404";
        ingress = {
          "next.jeffas.net" = {
            service = "http://${wwwLocal}";
          };
          "git.jeffas.net" = {
            service = "http://${gitLocal}";
          };
          "pages.jeffas.net" = {
            service = "http://${pagesLocal}";
          };
        };
      };
    };
  };

  services.nginx.virtualHosts."Tunnel WWW" = mkNginxConf {
    serverName = "www.jeffas.net ${wwwLocal}";
    root = "/local/git-pages/public-external/jeffasnet/";
    port = wwwPort;
  };

  services.nginx.virtualHosts."Tunnel Git" = mkNginxConf {
    serverName = "git.jeffas.net ${gitLocal}";
    root = "/local/git-www/public-external/";
    port = gitPort;
  };

  services.nginx.virtualHosts."Tunnel Pages" = mkNginxConf {
    serverName = "pages.jeffas.net ${pagesLocal}";
    root = "/local/git-pages/public-external/";
    port = pagesPort;
  };
}
