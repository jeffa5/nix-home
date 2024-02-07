{pkgs, ...}: let
  nc = pkgs.nextcloud-client;
  sourcedir = "/local/Cloud";
  cloudurl = "cloud.jeffas.net";
  runscript = pkgs.writeShellScriptBin "nc-sync" ''
    user=admin
    password=$(cat /var/lib/nextcloudcmd/password)
    ${nc}/bin/nextcloudcmd --non-interactive ${sourcedir} https://$user:$password@${cloudurl}
  '';
in {
  systemd.services.nextcloudcmd = {
    enable = true;
    description = "Sync nextcloud files";
    # unitConfig = {
    #   Type = "service";
    # };
    serviceConfig = {
      ExecStart = "${runscript}/bin/nc-sync";
    };
    wantedBy = ["multi-user.target"];
  };
}
