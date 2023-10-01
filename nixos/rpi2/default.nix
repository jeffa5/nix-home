{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    # ../modules/node-exporter.nix
    # ../modules/tailscale.nix
    # ../modules/glusterfs.nix
  ];

  networking.hostName = "rpi2";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
