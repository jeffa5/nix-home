{nixpkgs}: {pkgs, ...}: {
  imports = [
    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    ../modules/openssh.nix
    ../modules/node-exporter.nix
    ../modules/prometheus.nix
    ../modules/grafana.nix
    ../modules/nginx.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "23.05";
}
