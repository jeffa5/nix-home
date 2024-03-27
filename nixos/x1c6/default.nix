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
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "x1c6";

  services.printing = {
    enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };

  system.stateVersion = "23.11";
}
