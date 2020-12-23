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
        { modules
        , hostName
        }: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./nixos { inherit colemakdh hostName; })
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
        carbide = mkMachine {
          modules = [ ./nixos/carbide ];
          hostName = "carbide";
        };

        xps-15 = mkMachine {
          modules = [ ./nixos/xps-15 ];
          hostName = "xps-15";
        };
      };

      devShell.x86_64-linux =
        with nixpkgs.legacyPackages.x86_64-linux;
        pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt pkgs.rnix-lsp ];
        };
    };
}
