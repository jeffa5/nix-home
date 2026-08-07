{pkgs, ...}: let
  sourcedir = "/local/files";
  cloudurl = "https://cloud.jeffas.net";
  user = "Andrew";
in {
  systemd.services.nextcloudcmd = {
    enable = false;
    description = "One-way sync local files to Nextcloud";
    path = [pkgs.glibc];
    script = ''
      password=$(cat /var/lib/nextcloudcmd/password)
      obscured=$(${pkgs.rclone}/bin/rclone obscure "$password")
      ${pkgs.rclone}/bin/rclone copy \
        --webdav-url "${cloudurl}/remote.php/dav/files/${user}/" \
        --webdav-vendor nextcloud \
        --webdav-user "${user}" \
        --webdav-pass "$obscured" \
        --copy-links \
        --verbose \
        "${sourcedir}" \
        :webdav:
    '';
    serviceConfig = {
      Type = "oneshot";
      Environment = "HOME=/var/lib/nextcloudcmd";
    };
  };

  systemd.timers.nextcloudcmd = {
    enable = false;
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00";
      Persistent = true;
    };
  };
}
