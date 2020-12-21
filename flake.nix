{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { home-manager, nixpkgs, ... }:
    let machine = modules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.andrew = import ./home;
        }
      ] ++ modules;
    }; in
    {
      nixosConfigurations = {
        carbide = machine [ ./nixos/carbide ];

        xps-15 = machine [ ./nixos/xps-15 ];
      };

      devShell.x86_64-linux =
        with nixpkgs.legacyPackages.x86_64-linux;
        pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt pkgs.rnix-lsp ];
        };
    };
}
