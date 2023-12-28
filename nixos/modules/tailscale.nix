{...}: {
  services.tailscale.enable = true;

  networking.resolvconf.extraConfig = ''
    name_servers='100.85.109.140'
  '';
}
