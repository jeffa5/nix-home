{pkgs, ...}: let
  sourcedir = "/local/files";
  cloudurl = "https://cloud.jeffas.net";
  user = "Andrew";
in {
  systemd.services.nextcloudcmd = {
    enable = true;
    description = "One-way sync local files to Nextcloud";
    script = ''
      password=$(cat /var/lib/nextcloudcmd/password)
      obscured=$(${pkgs.rclone}/bin/rclone obscure "$password")
      ${pkgs.rclone}/bin/rclone copy \
        --webdav-url "${cloudurl}/remote.php/dav/files/${user}/" \
        --webdav-vendor nextcloud \
        --webdav-user "${user}" \
        --webdav-pass "$obscured" \
        "${sourcedir}" \
        :webdav:
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.nextcloudcmd = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00";
      Persistent = true;
    };
  };
}
