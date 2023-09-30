{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    ../modules/openssh.nix
    ../modules/node-exporter.nix
    ../modules/prometheus.nix
    ../modules/grafana.nix
    ../modules/nginx.nix
    ../modules/tailscale.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom

    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
