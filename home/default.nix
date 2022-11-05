{
  gui,
  username,
}: {
  config,
  pkgs,
  ...
}: let
  homeDirectory = "/home/${username}";

  guiPkgs =
    if gui
    then
      (with pkgs; [
        (import ./import-nef.nix pkgs)
        android-udev-rules
        anki
        bitwarden
        borgbackup
        chromium
        czkawka
        darktable
        element-desktop
        evince
        gitAndTools.git-open
        gnomeExtensions.caffeine
        gnomeExtensions.dash-to-dock
        gnomeExtensions.vitals
        inkscape
        libreoffice
        mendeley
        musescore
        nextcloud-client
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
        xdg-utils
        xournalpp
        xwayland
        zoom-us
      ])
    else [];

  tuiPkgs = with pkgs; [
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
  ];
in {
  imports = [
    ./xkb.nix
    (import ./latexmk.nix pkgs)
    (import ./neovim.nix pkgs)
    (import ./helix.nix pkgs)
    ./dconf.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
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

    file = {
      ".cargo/config".text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        [net]
        git-fetch-with-cli = true
      '';
    };
  };

  fonts.fontconfig.enable = gui;

  home.packages = guiPkgs ++ tuiPkgs;

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

    ssh = import ./ssh.nix;

    git = import ./git.nix pkgs;

    firefox =
      if gui
      then (import ./firefox.nix pkgs)
      else {};

    taskwarrior = {
      enable = gui;
    };

    tmux = import ./tmux.nix;

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
        vadimcn.vscode-lldb
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
