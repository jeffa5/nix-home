{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stableNixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    papers.url = "github:jeffa5/papers";
    tasknet.url = "github:jeffa5/tasknet";
    waytext.url = "github:jeffa5/waytext";
    wordnet-ls.url = "github:jeffa5/wordnet-ls";
    maills.url = "github:jeffa5/maills";
    icalls.url = "github:jeffa5/icalls";
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
    sway-overlay = _final: _prev: {
      status-bar = import packages/status-bar pkgs;
      sway-scripts = import packages/sway-scripts {
        inherit pkgs;
        lib = pkgs.lib;
      };
    };
    custom-overlay = _final: prev: {
      nix-search = nixSearch.packages.${system}.default;
      wordnet-ls = wordnet-ls.packages.${system}.wordnet-ls;
      maills = maills.packages.${system}.maills;
      icalls = icalls.packages.${system}.icalls;
      # khal =
      #   prev.khal.overrideAttrs
      #   (_finalAttrs: _previousAttrs: {
      #     src = prev.fetchFromGitHub {
      #       owner = "jeffa5";
      #       repo = "khal";
      #       rev = "35665e6c5a942621d686c55e809c9805d3c48c73"; # branch "myfeatures"
      #       sha256 = "sha256-MsNtyFAoNhqgD2cr1+KSD9U8JFHBklrSiTH1jh79sF8=";
      #     };
      #   });
    };
    overlays = [
      papers.overlays.default
      tasknet.overlays.default
      waytext.overlays.default
      sway-overlay
      custom-overlay
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
    };
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
              inherit colemakdh users gui nixpkgs overlays;
            })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home {
                inherit gui username;
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
          })
        ];
      };

      "${username}-tui" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (import ./home {
            inherit username;
            gui = false;
          })
        ];
      };
    };
    mkHomes = users: (
      lib.foldl (a: b: a // b) {} (map mkHomesForUser users)
    );
    piSystem = hostname:
      stableNixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          (import "${./nixos}/${hostname}" {
            nixpkgs = stableNixpkgs;
            configs = self.nixosConfigurations;
          })
        ];
      };
    piSSH = hostname:
      stableNixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4
          ./nixos/modules/openssh.nix
          {
            networking.hostName = hostname;
            system.stateVersion = "23.05";

            nixpkgs.config.allowUnfree = true;

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

      cubenas = stableNixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./nixos/cubenas {
            inherit nixpkgs;
            configs = self.nixosConfigurations;
          })
        ];
      };

      # rpi0 = stableNixpkgs.lib.nixosSystem {
      #   system = "aarch64-linux";
      #   modules = [
      #     hardware.nixosModules.raspberry-pi-4
      #     (import ./nixos/rpi0 {
      #       nixpkgs = stableNixpkgs;
      #       configs = self.nixosConfigurations;
      #     })
      #   ];
      # };
      #
      # rpi1 = piSystem "rpi1";
      #
      # rpi1ssh = piSSH "rpi1";
      #
      # rpi2 = piSystem "rpi2";
      #
      # rpi2ssh = piSSH "rpi2";
    };

    # standalone home environment
    # home-manager switch --flake '<flake-uri>#andrew'
    # to install
    homeConfigurations =
      (mkHomes ["andrew" "apj39"])
      // {
        ajeffery = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [./home/cloudflare];
        };
      };

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

      deploy = pkgs.callPackage ./deploy.nix {hosts = import ./nixos/hosts.nix;};

      nvd = pkgs.writeShellScriptBin "nvd" ''
        set -e
        nixos-rebuild build --flake . # get the to-be-installed closure
        ${pkgs.lib.getExe pkgs.nvd} diff /run/current-system ./result # diff that with the current system
      '';
    };

    checks.${system} = {
      nixfmt = self.packages.${system}.nixfmt;
      deadnix = self.packages.${system}.deadnix;
    };

    formatter.${system} = pkgs.alejandra;
  };
}
