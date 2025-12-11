{...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "1653cea6-96b2-44f4-9984-d90efb9d748e" = {
        credentialsFile = "/local/cloudflared/cert.pem";
        default = "http_status:404";
      };
    };
  };

  services.nginx.virtualHosts."Tunnel WWW" = {
    serverName = "www.jeffas.net";
    root = "/local/git-pages/jeffasnet/";
    listen = [
      {
        addr = "127.0.0.1";
        port = 3080;
      }
    ];
  };

  services.nginx.virtualHosts."Tunnel Git" = {
    serverName = "git.jeffas.net";
    root = "/local/git-www/";
    listen = [
      {
        addr = "127.0.0.1";
        port = 3081;
      }
    ];
  };

  services.nginx.virtualHosts."Tunnel Pages" = {
    serverName = "pages.jeffas.net";
    root = "/local/git-pages/";
    listen = [
      {
        addr = "127.0.0.1";
        port = 3082;
      }
    ];
  };
}
