{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/promtail.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "x1gen6";
  # networking.interfaces.wlp2s0.useDHCP = true;

  # services.printing = {
  #   enable = true;
  #   clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  # };
}
