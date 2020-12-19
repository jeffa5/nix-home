{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { home-manager, nixpkgs, ... }:
    {
      nixosConfigurations = {
        carbide = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos
            ./nixos/carbide
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.andrew = import ./home.nix;
            }
          ];
        };

        xps-15 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos
            ./nixos/xps-15
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.andrew = import ./home.nix;
            }
          ];
        };
      };

      devShell.x86_64-linux =
        with nixpkgs.legacyPackages.x86_64-linux;
        pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt pkgs.rnix-lsp ];
        };
    };
}
