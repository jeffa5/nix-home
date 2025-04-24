{
  nixpkgs,
  configs,
}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    ../modules/kubenode.nix
  ];

  networking.hostName = "rpi0";

  environment.systemPackages = [
    pkgs.git
    pkgs.htop
    pkgs.iftop
    pkgs.iotop
  ];

  system.stateVersion = "24.11";
}
