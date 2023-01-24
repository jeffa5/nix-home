{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    papers.url = "github:jeffa5/papers";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    hardware,
    papers,
  }: let
    username = "andrew";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [papers.overlays.default];
    };
    colemakdh = import packages/colemakdh pkgs;
    lib = pkgs.lib;
    mkMachine = {
      modules,
      users,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            (import ./nixos {
              inherit colemakdh nixpkgs users;
              overlays = [papers.overlays.default];
            })
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
      carbide = mkMachine {
        modules = [./nixos/carbide];
        users = ["andrew"];
      };

      xps-15 = mkMachine {
        modules = [./nixos/xps-15 hardware.nixosModules.dell-xps-15-9560];
        users = ["andrew"];
      };
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
