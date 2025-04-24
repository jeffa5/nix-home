{nixpkgs, ...}: {
  imports = [
    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    ./node-exporter.nix
    ./tailscale.nix
  ];
}
