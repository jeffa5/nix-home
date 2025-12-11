{...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "bb0853ce-9799-4f0f-9b0d-80250eae1002" = {
        credentialsFile = "/local/cloudflared/bb0853ce-9799-4f0f-9b0d-80250eae1002.json";
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
