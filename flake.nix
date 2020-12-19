{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { home-manager, nixpkgs, ... }:
    let
        nixpkgs = import nixpkgs {
          config = { allowUnfree = true; };
        };
      in
  {

    nixosConfigurations = {
      carbide =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./carbide
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andrew = import ./home.nix;
          }
        ];
      };
    };
  };
}
