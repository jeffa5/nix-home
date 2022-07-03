{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
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
      stateVersion = "21.11";
      lib = nixpkgs.lib;
      mkMachine =
        modules: nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./nixos { inherit colemakdh nixpkgs; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = (import ./home { gui = true; username = "andrew"; });
            }
          ] ++ modules;
        };
      mkHomesForUser = username: {
        ${username} = home-manager.lib.homeManagerConfiguration {
          configuration = import ./home { inherit username; gui = true; };
          inherit system username stateVersion;
          homeDirectory = "/home/${username}";
        };

        "${username}-tui" = home-manager.lib.homeManagerConfiguration {
          configuration = import ./home { inherit username; gui = false; };
          inherit system username stateVersion;
          homeDirectory = "/home/${username}";
        };
      };
      mkHomes = users: (
        lib.foldl (a: b: a // b) { } (map mkHomesForUser users)
      );
    in
    {
      # whole system configs
      # nixos-rebuild switch --flake '<flake-uri>#xps-15'
      # to install
      nixosConfigurations = {
        carbide = mkMachine [ ./nixos/carbide ];

        xps-15 = mkMachine [ ./nixos/xps-15 ];
      };

      # standalone home environment
      # home-manager switch --flake '<flake-uri>#andrew'
      # to install
      homeConfigurations = mkHomes [ "andrew" "apj39" ];

      devShells.${system}.default =
        with nixpkgs.legacyPackages.${system};
        pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-fmt rnix-lsp ];
        };
    };
}
