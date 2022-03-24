{ config, pkgs, ... }:

let
  username = "andrew";
  homeDirectory = "/home/${username}";
in

{
  imports = [
    ./xkb.nix
    (import ./latexmk.nix pkgs)
    (import ./neovim.nix pkgs)
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    inherit homeDirectory;
    username = "${username}";
    sessionPath = [ "${homeDirectory}/.cargo/bin" ];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "vim";
    };

    stateVersion = "21.11";

    file = {
      ".cargo/config".text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      '';
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    android-udev-rules
    htop
    xwayland
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
    bat
    wl-clipboard
    ripgrep
    tree
    filelight
    czkawka
    ark
    lm_sensors
    fd
    xdg_utils
    libreoffice
    lf
    borgbackup
    vorta
    prettyping
    darktable
    gitAndTools.git-open
    git-extras
    xournalpp
    mendeley
    signal-desktop
    chromium
    (import ./import-nef.nix pkgs)
    thunderbird
    slack
    skypeforlinux
    krb5 # for cl access
    okular
    vlc
    inkscape
    bitwarden
    zoom-us
    sccache
    nextcloud-client
    kubectx
    just
    file
    todoist-electron

    jq
    texlab
    anki

    wally-cli

    ferdi
  ];

  programs = {
    home-manager.enable = true;

    alacritty = import ./alacritty.nix pkgs;

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

    ssh = import ./ssh.nix;

    git = import ./git.nix pkgs;

    firefox = import ./firefox.nix pkgs;

    mako = import ./mako.nix;

    taskwarrior = {
      enable = true;
    };

    tmux = import ./tmux.nix;

    zathura = import ./zathura.nix;

    zsh = import ./zsh.nix pkgs;

    fish = import ./fish.nix pkgs;

    nix-index.enable = true;

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        matklad.rust-analyzer
      ];
    };
  };

  services = {
    nextcloud-client = {
      enable = true;
    };

    wlsunset = {
      enable = true;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };
}
