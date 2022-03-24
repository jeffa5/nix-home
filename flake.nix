{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      colemakdh = import packages/colemakdh nixpkgs;
      status-bar = import packages/status-bar nixpkgs;
      sway-scripts = import packages/sway-scripts nixpkgs;
      mkMachine =
        modules: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./nixos { inherit colemakdh nixpkgs; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.andrew = (import ./home);
            }
          ] ++ modules;
        };
    in
    {
      nixosConfigurations = {
        carbide = mkMachine [ ./nixos/carbide ];

        xps-15 = mkMachine [ ./nixos/xps-15 ];
      };

      devShell.x86_64-linux =
        with nixpkgs.legacyPackages.x86_64-linux;
        pkgs.mkShell {
          buildInputs = with pkgs; [ dconf2nix nixpkgs-fmt rnix-lsp ];
        };
    };
}
