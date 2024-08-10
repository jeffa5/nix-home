{...}: {
  services.tailscale.enable = true;

  networking.resolvconf.extraConfig = ''
    name_servers='100.106.84.46'
  '';
  networking.nameservers = ["100.106.84.46"];
}
