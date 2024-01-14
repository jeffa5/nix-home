{nixpkgs}: {pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../modules/rpi.nix

    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    (import ../modules/node-exporter.nix {openFirewall = true;})
    (import ../modules/promtail.nix {openFirewall = true;})
    ../modules/nginx.nix
    ../modules/tailscale.nix
  ];

  networking.hostName = "rpi2";

  environment.systemPackages = with pkgs; [
    htop
    iotop
  ];

  system.stateVersion = "23.05";
}
