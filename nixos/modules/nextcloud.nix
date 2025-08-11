{
  pkgs,
  lib,
  ...
}: let
  serverName = "cloud.home.jeffas.net";
in {
  services.nextcloud = {
    enable = true;
    hostName = serverName;
    config = {
      dbtype = "sqlite";
      adminuser = "Admin";
      adminpassFile = "/etc/nextcloud/admin-pass";
    };
    extraOptions."memories.exiftool" = lib.getExe pkgs.exiftool;
    extraOptions."memories.vod.ffmpeg" = lib.getExe pkgs.ffmpeg-headless;
    extraOptions."memories.vod.ffprobe" = lib.getExe' pkgs.ffmpeg-headless "ffprobe";
    extraOptions."maintenance_window_start" = 2;
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
