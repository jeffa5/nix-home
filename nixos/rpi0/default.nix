{nixpkgs, configs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/dnsmasq.nix {inherit configs;})

    ../modules/nginx.nix
    ../modules/zigbee2mqtt.nix
    ../modules/mosquitto.nix
    ../modules/influxdb.nix

    (import ../modules/kubenode.nix {inherit nixpkgs;})
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
