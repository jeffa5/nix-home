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
    # metrics
    ../modules/node-exporter.nix
    ../modules/promtail.nix
    ../modules/prometheus.nix
    # visualization
    ../modules/grafana.nix
    # logging
    ../modules/loki.nix
    # serving
    (import ../modules/dnsmasq.nix {inherit configs;})
    ../modules/nginx.nix
    ../modules/tailscale.nix
    (import ../modules/homeboard.nix {inherit configs;})
    # misc
    ../modules/taskserver.nix
    # smart home
    ../modules/zigbee2mqtt.nix
    ../modules/mosquitto.nix
    ../modules/influxdb.nix
  ];

  services.homeboard.enable = true;

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
