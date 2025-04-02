{
  gui,
  username,
  wordnet-ls,
  maills,
  icalls,
  nixSearch,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  homeDirectory = "/home/${username}";

  tuiPkgs =
    [
      pkgs.nerd-fonts.hack
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-cjk-sans
      pkgs.fd
      pkgs.file
      pkgs.git-extras
      pkgs.wget
      pkgs.htop
      pkgs.iftop
      pkgs.jq
      pkgs.lf
      pkgs.lm_sensors
      pkgs.ripgrep
      pkgs.sccache
      pkgs.tree
      pkgs.cachix
      pkgs.ncdu
      pkgs.powertop
      pkgs.unzip
      nixSearch
    ]
    ++ [
      (pkgs.callPackage ./weekly.nix {})
      (pkgs.callPackage ./daily.nix {})
    ];
in {
  imports =
    [
      ./xkb.nix
      ./latexmk.nix
      (import ./neovim.nix {inherit wordnet-ls maills icalls;})
      ./helix.nix
      ./modules/cargo.nix
      ./modules/nix.nix
      ./ssh.nix
      ./git.nix
      ./jujutsu.nix
      (import ./tmux.nix {server = !gui;})
      ./zsh.nix
      ./fish.nix
      ./nushell.nix
    ]
    ++ (
      if gui
      then [
        ./modules/gui.nix
      ]
      else []
    );

  nix.package = lib.mkForce pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };
  nix.extraOptions = ''
    !include /home/${username}/.config/nix/extra.conf
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "image/svg+xml" = ["imv.desktop"];
      "image/jpeg" = ["imv.desktop"];
      "image/jpg" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["writer.desktop"];
      "application/vnd.oasis.opendocument.text" = ["writer.desktop"];
      "application/vnd.oasis.opendocument.spreadsheet" = ["calc.desktop"];
    };
  };

  home = {
    inherit homeDirectory username;
    sessionPath = ["${homeDirectory}/.cargo/bin"];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "nvim";
    };

    stateVersion = "21.11";
  };

  home.packages = tuiPkgs;

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-light";
      };
    };

    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    eza = {
      enable = true;
      # doesn't work well with nushell as it doesn't output a table
      enableNushellIntegration = false;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    nix-index.enable = true;
  };
}
