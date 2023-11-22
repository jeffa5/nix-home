{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    (import ../modules/node-exporter.nix {openFirewall = true;})
    ../modules/prometheus.nix
    ../modules/grafana.nix
    ../modules/nginx.nix
    ../modules/tailscale.nix
    ../modules/taskserver.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
