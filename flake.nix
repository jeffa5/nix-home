{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
  }: let
    colemakdh = import packages/colemakdh nixpkgs;
    username = "andrew";
    system = "x86_64-linux";
    stateVersion = "21.11";
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;
    mkMachine = modules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            (import ./nixos {inherit colemakdh nixpkgs;})
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home {
                gui = true;
                username = "andrew";
              };
            }
          ]
          ++ modules;
      };
    mkHomesForUser = username: {
      ${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home/default.nix {
            inherit username;
            gui = true;
          })
        ];
      };

      "${username}-tui" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home/default.nix {
            inherit username;
            gui = false;
          })
        ];
      };
    };
    mkHomes = users: (
      lib.foldl (a: b: a // b) {} (map mkHomesForUser users)
    );
  in {
    # whole system configs
    # nixos-rebuild switch --flake '<flake-uri>#xps-15'
    # to install
    nixosConfigurations = {
      carbide = mkMachine [./nixos/carbide];

      xps-15 = mkMachine [./nixos/xps-15];
    };

    # standalone home environment
    # home-manager switch --flake '<flake-uri>#andrew'
    # to install
    homeConfigurations = mkHomes ["andrew" "apj39"];

    packages.${system} = {
      nixfmt =
        pkgs.runCommand "nixfmt"
        {
          buildInputs = [pkgs.alejandra];
        } ''
          alejandra --check ${./.}
          mkdir $out
        '';
      deadnix = pkgs.runCommand "deadnix" {buildInputs = [pkgs.deadnix];} ''
        deadnix --fail ${./.}
        mkdir $out
      '';
    };

    checks.${system} = {
      nixfmt = self.packages.${system}.nixfmt;
      deadnix = self.packages.${system}.deadnix;
    };

    formatter.${system} = pkgs.alejandra;

    devShells.${system}.default = with pkgs;
      pkgs.mkShell {
        buildInputs = with pkgs; [rnix-lsp dconf2nix];
      };
  };
}
