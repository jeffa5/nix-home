{...}: {
  services.tailscale.enable = true;

  networking.resolvconf.extraConfig = "";
  networking.nameservers = ["100.106.58.97"];
}
