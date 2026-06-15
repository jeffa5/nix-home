{
  pkgs,
  lib,
  ...
}: let
  serverName = "cloud.home.jeffas.net";
in {
  services.nextcloud = {
    enable = false;
    package = pkgs.nextcloud32;
    hostName = serverName;
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = "Admin";
      adminpassFile = "/etc/nextcloud/admin-pass";
    };
    extraApps = {
      inherit (pkgs.nextcloud32Packages.apps) memories user_oidc;
    };
    settings."memories.exiftool" = lib.getExe pkgs.exiftool;
    settings."memories.vod.ffmpeg" = lib.getExe pkgs.ffmpeg-headless;
    settings."memories.vod.ffprobe" = lib.getExe' pkgs.ffmpeg-headless "ffprobe";
    settings."maintenance_window_start" = 2;
  };

  systemd.services.nextcloud-cron = {
    path = [pkgs.ffmpeg];
  };

  services.nginx.virtualHosts.${serverName} = {
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
