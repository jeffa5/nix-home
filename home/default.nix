{ status-bar, sway-scripts, waytext }:
{ config, pkgs, ... }:

let homeDirectory = "/home/andrew"; in

{
  imports = [
    (import ./aerc.nix pkgs)
    # ./swaylock.nix
    ./xkb.nix
    (import ./latexmk.nix pkgs)
    (import ./wofi.nix)
    (import ./neovim.nix pkgs)
    # ./imv.nix
    # ./dconf.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    inherit homeDirectory;
    username = "andrew";
    sessionPath = [ "${homeDirectory}/.cargo/bin" ];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      # XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "vim";
    };

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
    aerc
    wofi
    bat
    wl-clipboard
    ripgrep
    playerctl
    pamixer
    tree
    # swaylock
    # swayidle
    lm_sensors
    fd
    xdg_utils
    libreoffice
    lf
    borgbackup
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
    # imv
    skype
    pavucontrol
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
  ] ++ [ waytext.packages.x86_64-linux.waytext ];

  programs = {
    home-manager.enable = true;

    alacritty = import ./alacritty.nix pkgs;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      nix-direnv = {
        enable = true;
        enableFlakes = true;
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
      settings = {
        nix_shell = {
          disabled = false;
        };
        kubernetes = {
          disabled = false;
        };
      };
    };

    ssh = import ./ssh.nix;

    git = import ./git.nix pkgs;

    firefox = import ./firefox.nix pkgs;

    mako = import ./mako.nix;

    taskwarrior = {
      enable = true;
    };

    tmux = import ./tmux.nix;

    waybar = import ./waybar.nix { inherit pkgs status-bar; };

    zathura = import ./zathura.nix;

    zsh = import ./zsh.nix pkgs;

    fish = import ./fish.nix pkgs;

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        matklad.rust-analyzer
      ];
    };
  };

  wayland.windowManager.sway = import ./sway.nix { inherit pkgs sway-scripts; };

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
