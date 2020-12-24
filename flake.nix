{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { home-manager, nixpkgs, ... }:
    let
      colemakdh = import ./colemakdh nixpkgs;
      mkMachine =
        modules: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./nixos { inherit colemakdh; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.andrew = import ./home;
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
