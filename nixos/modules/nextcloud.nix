{
  pkgs,
  lib,
  ...
}: let
  serverName = "cloud.home.jeffas.net";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = serverName;
    config = {
      dbtype = "sqlite";
      adminuser = "Admin";
      adminpassFile = "/etc/nextcloud/admin-pass";
    };
    settings."memories.exiftool" = lib.getExe pkgs.exiftool;
    settings."memories.vod.ffmpeg" = lib.getExe pkgs.ffmpeg-headless;
    settings."memories.vod.ffprobe" = lib.getExe' pkgs.ffmpeg-headless "ffprobe";
    settings."maintenance_window_start" = 2;
  };

  systemd.services.nextcloud-cron = {
    path = [pkgs.ffmpeg];
  };

  services.nginx.virtualHosts."${serverName}" = {
    inherit serverName;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:80";
    #     # proxyWebsockets = true;
    #   };
  };
}
