{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    # metrics
    (import ../modules/node-exporter.nix {openFirewall = true;})
    ../modules/prometheus.nix
    # visualization
    ../modules/grafana.nix
    # logging
    ../modules/loki.nix
    (import ../modules/promtail.nix {openFirewall = true;})
    # serving
    ../modules/dnsmasq.nix
    ../modules/nginx.nix
    ../modules/tailscale.nix
    # misc
    ../modules/taskserver.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
