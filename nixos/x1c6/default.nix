{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/promtail.nix
    ../modules/printing.nix
    ../modules/scanning.nix
    ../modules/syncthing.nix
  ];

  services.backups.enable = true;
  services.backups.user = "andrew";

  # override to use performance profile when charging
  services.auto-cpufreq.settings.charger.governor = "performance";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "x1c6";

  system.stateVersion = "23.11";
}
