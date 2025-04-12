{pkgs, ...}: let
  st = "${pkgs.libsecret}/bin/secret-tool";
in {
  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "ocnews" # ownCloud which matches NextCloud
      ocnews-url "https://cloud.jeffas.net"
      ocnews-login "Admin"
      ocnews-passwordeval "${st} lookup type news account Admin"

      color listfocus default default reverse
      color listfocus_unread default default bold reverse
      color title default default reverse
      color info default default reverse
    '';
  };
}
