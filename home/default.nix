{
  gui,
  username,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  homeDirectory = "/home/${username}";

  tuiPkgs = with pkgs;
    [
      (nerdfonts.override {fonts = ["Hack"];})
      fd
      file
      git-extras
      htop
      jq
      just
      krb5 # for cl access
      kubectx
      lf
      lm_sensors
      prettyping
      ripgrep
      sccache
      tree
      cachix
      ncdu
      powertop
      unzip
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
      ./neovim.nix
      ./helix.nix
      ./modules/cargo.nix
      ./modules/papers.nix
      ./ssh.nix
      ./git.nix
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

  nixpkgs.config.allowUnfree = true;
  nix.package = lib.mkForce pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

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
    };
  };

  home = {
    inherit homeDirectory username;
    sessionPath = ["${homeDirectory}/.cargo/bin"];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "vim";
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

    exa = {
      enable = true;
      enableAliases = true;
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
