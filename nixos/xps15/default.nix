{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/alloy.nix
    ../modules/printing.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "xps15";
  networking.interfaces.wlp2s0.useDHCP = true;
}
