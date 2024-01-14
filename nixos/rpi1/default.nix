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
    (import ../modules/node-exporter.nix {openFirewall = true;})
    (import ../modules/promtail.nix {openFirewall = true;})
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
  ];

  services.homeboard.enable = true;

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
