{ gui }:
{ config, pkgs, ... }:

let
  username = "andrew";
  homeDirectory = "/home/${username}";

  guiPkgs =
    if gui then
      (with pkgs; [
        (import ./import-nef.nix pkgs)
        android-udev-rules
        anki
        ark
        bitwarden
        borgbackup
        chromium
        czkawka
        darktable
        ferdi
        filelight
        gitAndTools.git-open
        inkscape
        libreoffice
        mendeley
        nextcloud-client
        okular
        signal-desktop
        skypeforlinux
        slack
        spotify
        texlab
        thunderbird
        todoist-electron
        vlc
        vorta
        wally-cli
        wl-clipboard
        xdg_utils
        xournalpp
        xwayland
        zoom-us
      ]) else [ ];

  tuiPkgs = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
    bat
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
  ];
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

  fonts.fontconfig.enable = gui;

  home.packages = guiPkgs ++ tuiPkgs;

  programs = {
    home-manager.enable = true;

    alacritty = if gui then (import ./alacritty.nix pkgs) else { };

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

    firefox = if gui then (import ./firefox.nix pkgs) else { };

    taskwarrior = {
      enable = gui;
    };

    tmux = import ./tmux.nix;

    zathura = if gui then (import ./zathura.nix) else { };

    zsh = import ./zsh.nix pkgs;

    fish = import ./fish.nix pkgs;

    nushell = {
      enable = true;
    };

    nix-index.enable = true;

    vscode = {
      enable = gui;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        matklad.rust-analyzer
      ];
    };
  };

  services = {
    nextcloud-client = {
      enable = gui;
    };

    wlsunset = {
      enable = gui;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };
}
