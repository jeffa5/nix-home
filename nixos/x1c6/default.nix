{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/promtail.nix
    # ../modules/printing.nix
    # ../modules/scanning.nix
    ../modules/syncthing.nix
  ];

  services.backups.enable = true;
  services.backups.user = "andrew";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "x1c6";

  system.stateVersion = "23.11";
}
