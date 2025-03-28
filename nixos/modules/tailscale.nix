{...}: {
  services.tailscale.enable = true;

  networking.resolvconf.extraConfig = "";
  networking.nameservers = [];
}
