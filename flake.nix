{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stableNixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    papers.url = "github:jeffa5/papers";
    tasknet.url = "github:jeffa5/tasknet";
    waytext.url = "github:jeffa5/waytext";
    wordnet-ls = {
      url = "github:jeffa5/wordnet-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    maills = {
      url = "github:jeffa5/maills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    icalls = {
      url = "github:jeffa5/icalls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixSearch.url = "github:diamondburned/nix-search";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    stableNixpkgs,
    hardware,
    papers,
    tasknet,
    waytext,
    wordnet-ls,
    maills,
    icalls,
    nixSearch,
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
    wordnet-lspkg = wordnet-ls.packages.${system}.wordnet-ls;
    maillsPkg = maills.packages.${system}.maills;
    icallsPkg = icalls.packages.${system}.icalls;
    nixSearchPkg = nixSearch.packages.${system}.default;
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
              inherit colemakdh users gui;
              nixpkgs = nixpkgs;
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
                inherit gui username;
                wordnet-ls = wordnet-lspkg;
                maills = maillsPkg;
                icalls = icallsPkg;
                nixSearch = nixSearchPkg;
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
            wordnet-ls = wordnet-lspkg;
            maills = maillsPkg;
            icalls = icallsPkg;
            nixSearch = nixSearchPkg;
          })
        ];
      };

      "${username}-tui" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home {
            inherit username;
            gui = false;
            wordnet-ls = wordnet-lspkg;
            maills = maillsPkg;
            icalls = icallsPkg;
            nixSearch = nixSearchPkg;
          })
        ];
      };
    };
    mkHomes = users: (
      lib.foldl (a: b: a // b) {} (map mkHomesForUser users)
    );
    piSSH = hostname:
      stableNixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          ./nixos/modules/openssh.nix
          {
            networking.hostName = hostname;
            system.stateVersion = "23.05";

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
              fsType = "ext4";
            };
          }
        ];
      };
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

      rpi1 = stableNixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          (import ./nixos/rpi1 {
            nixpkgs = stableNixpkgs;
            configs = self.nixosConfigurations;
          })
        ];
      };

      rpi1ssh = piSSH "rpi1";

      rpi2 = stableNixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          (import ./nixos/rpi2 {nixpkgs = stableNixpkgs;})
        ];
      };

      rpi2ssh = piSSH "rpi2";

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

      nvd = pkgs.writeShellScriptBin "nvd" ''
        nixos-rebuild build --flake . # get the to-be-installed closure
        nix run nixpkgs#nvd -- diff /run/current-system ./result # diff that with the current system
      '';
    };

    checks.${system} = {
      nixfmt = self.packages.${system}.nixfmt;
      deadnix = self.packages.${system}.deadnix;
    };

    formatter.${system} = pkgs.alejandra;
  };
}
