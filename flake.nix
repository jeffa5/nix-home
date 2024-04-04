{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    papers.url = "github:jeffa5/papers";
    tasknet.url = "github:jeffa5/tasknet";
    waytext.url = "github:jeffa5/waytext";
    lls.url = "github:jeffa5/lls";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    hardware,
    papers,
    tasknet,
    waytext,
    lls,
  }: let
    username = "andrew";
    system = "x86_64-linux";
    sway-overlay = _final:_prev: {
      status-bar = import packages/status-bar pkgs;
      sway-scripts = import packages/sway-scripts {
        inherit pkgs;
        lib = pkgs.lib;
      };
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        papers.overlays.default
        tasknet.overlays.default
        waytext.overlays.default
        sway-overlay
      ];
    };
    llspkg = lls.packages.${system}.lls;
    colemakdh = import packages/colemakdh pkgs;
    lib = pkgs.lib;
    mkMachine = {
      modules,
      users,
      gui,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            (import ./nixos {
              inherit colemakdh nixpkgs users gui;
              overlays = [
                papers.overlays.default
                waytext.overlays.default
                sway-overlay
              ];
            })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home {
                inherit gui;
                username = "andrew";
                lls = llspkg;
              };
            }
          ]
          ++ modules;
      };
    mkHomesForUser = username: {
      ${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home {
            inherit username;
            gui = true;
            lls = llspkg;
          })
        ];
      };

      "${username}-tui" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home {
            inherit username;
            gui = false;
            lls = llspkg;
          })
        ];
      };
    };
    mkHomes = users: (
      lib.foldl (a: b: a // b) {} (map mkHomesForUser users)
    );
  in {
    # whole system configs
    # nixos-rebuild switch --flake '<flake-uri>#xps15'
    # to install
    nixosConfigurations = {
      carbide = mkMachine {
        modules = [./nixos/carbide];
        users = ["andrew"];
        gui = true;
      };

      xps15 = mkMachine {
        modules = [./nixos/xps15 hardware.nixosModules.dell-xps-15-9560-intel];
        users = ["andrew"];
        gui = true;
      };

      x1c6 = mkMachine {
        modules = [./nixos/x1c6 hardware.nixosModules.lenovo-thinkpad-x1-6th-gen];
        users = ["andrew"];
        gui = true;
      };

      rpi1 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          (import ./nixos/rpi1 {
            inherit nixpkgs;
            configs = self.nixosConfigurations;
          })
        ];
      };

      rpi2 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          (import ./nixos/rpi2 {inherit nixpkgs;})
        ];
      };

      # rosebud = nixpkgs.lib.nixosSystem {
      #   inherit system pkgs;
      #   modules = [
      #     tasknet.nixosModules.${system}.tasknet-server
      #     ./nixos/rosebud
      #   ];
      # };
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

      deploy = pkgs.callPackage ./deploy.nix {hosts = import ./hosts.nix;};
    };

    checks.${system} = {
      nixfmt = self.packages.${system}.nixfmt;
      deadnix = self.packages.${system}.deadnix;
    };

    formatter.${system} = pkgs.alejandra;
  };
}
