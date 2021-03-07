{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waytext = {
      url = "github:jeffa5/waytext/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, waytext }:
    let
      colemakdh = import packages/colemakdh nixpkgs;
      status-bar = import packages/status-bar nixpkgs;
      sway-scripts = import packages/sway-scripts nixpkgs;
      mkMachine =
        modules: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./nixos { inherit colemakdh; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.andrew = (import ./home {
                inherit status-bar sway-scripts waytext;
              });
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
          buildInputs = [ pkgs.nixpkgs-fmt pkgs.rnix-lsp ];
        };
    };
}
