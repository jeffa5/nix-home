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
      username = "andrew";
      system = "x86_64-linux";
      mkMachine =
        modules: nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./nixos { inherit colemakdh nixpkgs; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = (import ./home { gui = true; });
            }
          ] ++ modules;
        };
    in
    {
      # whole system configs
      # nixos-rebuild switch --flake '<flake-uri>#andrew'
      # to install
      nixosConfigurations = {
        carbide = mkMachine [ ./nixos/carbide ];

        xps-15 = mkMachine [ ./nixos/xps-15 ];
      };

      # standalone home environment
      # home-manager switch --flake '<flake-uri>#andrew'
      # to install
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        configuration = import ./home { gui = true; };
        inherit system username;
        homeDirectory = "/home/${username}";
        stateVersion = "21.11";
      };

      homeConfigurations.andrew-tui = home-manager.lib.homeManagerConfiguration {
        configuration = import ./home { gui = false; };
        inherit system username;
        homeDirectory = "/home/${username}";
        stateVersion = "21.11";
      };

      devShell.${system} =
        with nixpkgs.legacyPackages.${system};
        pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-fmt rnix-lsp ];
        };
    };
}
