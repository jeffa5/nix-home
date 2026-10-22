{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    ../modules/laptop.nix
    ../modules/node-exporter.nix
    ../modules/alloy.nix
    ../modules/btrfs.nix
    # ../modules/printing.nix
    # ../modules/scanning.nix

    ../modules/steam.nix
  ];

  services.backups.enable = true;
  services.backups.user = "andrew";

  # 06cb:009a (Synaptics/Validity) sensor isn't supported by upstream libfprint yet.
  # Using bingch's libfprint-tod driver (verify-only) with calibration data dumped
  # earlier via the python-validity backend, so this integrates properly with
  # fprintd/PAM (sudo, login) instead of open-fprintd.
  # Calibration data is per-laptop hardware state, not config, so it stays out of
  # the repo and is read from where python-validity originally wrote it, via a
  # hash-pinned fetchurl (plain path would need --impure). If the sensor is ever
  # recalibrated, update the hash with:
  #   nix hash file --type sha256 /var/lib/python-validity/calib-data.bin
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "libfprint-tod";
    calib-data-file = builtins.fetchurl {
      url = "file:///var/lib/python-validity/calib-data.bin";
      sha256 = "sha256-jFvpznANb/rit2siLWq50g1R7eOTWUQgFzRRWGpuMGw=";
    };
  };

  environment.systemPackages = [pkgs.nextcloud-client];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.supportedFilesystems = ["btrfs"];

  # Fix for Intel iGPU freeze/blank screen after suspend/resume and hibernate
  boot.kernelParams = ["i915.enable_psr=0"];

  networking.hostName = "x1c6";

  system.stateVersion = "23.11";
}
