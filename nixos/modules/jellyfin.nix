{pkgs, ...}: let
  http_port = 8096;
in {
  services.jellyfin = {
    enable = true;
  };
  environment.systemPackages = [
    #     pkgs.jellyfin
    # pkgs.jellyfin-web
    # pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."Jellyfin" = {
    serverName = "jellyfin.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString http_port}";
      proxyWebsockets = true;
    };
  };
}
