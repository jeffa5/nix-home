{...}: let
  ns = "100.121.99.93";
in {
  services.tailscale.enable = true;

  # networking.resolvconf.extraConfig = ''
  #   name_servers='${ns}'
  # '';
  networking.nameservers = [ns];
}
