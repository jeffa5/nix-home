{
  nixpkgs,
  configs,
}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
  ];

  networking.hostName = "rpi0";

  environment.systemPackages = [
    pkgs.htop
    pkgs.iftop
    pkgs.iotop
  ];

  system.stateVersion = "24.11";
}
