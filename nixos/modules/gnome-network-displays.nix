{pkgs, ...}: {
  environment.systemPackages = [pkgs.gnome-network-displays];

  # Required for discovering and announcing receivers/senders on the LAN.
  # openFirewall (default) takes care of UDP 5353 for mDNS.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
