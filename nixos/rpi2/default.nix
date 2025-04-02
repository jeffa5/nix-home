{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    ../modules/node-exporter.nix
    ../modules/promtail.nix
    ../modules/nginx.nix
    ../modules/tailscale.nix
    ../modules/nextcloudcmd.nix
  ];

  networking.hostName = "rpi2";

  environment.systemPackages = [
    pkgs.htop
    pkgs.iftop
    pkgs.iotop
  ];

  system.stateVersion = "23.05";
}
