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
    ../modules/prometheus.nix
    # visualization
    ../modules/grafana.nix
    # logging
    ../modules/loki.nix
    ../modules/promtail.nix
    # serving
    (import ../modules/dnsmasq.nix {inherit configs;})
    ../modules/nginx.nix
    ../modules/tailscale.nix
    (import ../modules/homeboard.nix {inherit configs;})
    # misc
    # ../modules/taskserver.nix
    # smart home
    ../modules/zigbee2mqtt.nix
    ../modules/mosquitto.nix
    ../modules/influxdb.nix
    # data
    ../modules/nextcloudcmd.nix
  ];

  services.homeboard.enable = true;

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    htop
    iftop
    iotop
  ];

  system.stateVersion = "23.05";
}
