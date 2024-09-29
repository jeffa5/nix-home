{pkgs, ...}: let
  nc = pkgs.nextcloud-client;
  sourcedir = "/local/Cloud";
  cloudurl = "cloud.jeffas.net";
in {
  systemd.services.nextcloudcmd = {
    enable = true;
    description = "Sync nextcloud files";
    script = ''
      user=Admin
      password=$(cat /var/lib/nextcloudcmd/password)
      ${nc}/bin/nextcloudcmd --non-interactive ${sourcedir} https://$user:$password@${cloudurl}
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.timers.nextcloudcmd = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "15m";
    };
  };
}
