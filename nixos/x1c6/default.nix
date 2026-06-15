{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/alloy.nix
    # ../modules/printing.nix
    # ../modules/scanning.nix

    ../modules/steam.nix
  ];

  services.backups.enable = true;
  services.backups.user = "andrew";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.supportedFilesystems = ["btrfs"];

  # Fix for Intel iGPU freeze/blank screen after suspend/resume and hibernate
  boot.kernelParams = ["i915.enable_psr=0"];

  networking.hostName = "x1c6";

  system.stateVersion = "23.11";
}
