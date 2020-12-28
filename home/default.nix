{ status-bar, sway-scripts }:
{ config, pkgs, ... }:

{
  imports = [ (import ./aerc.nix pkgs) ./swaylock.nix ./xkb.nix ];

  nixpkgs.config.allowUnfree = true;

  home = rec {
    username = "andrew";
    homeDirectory = "/home/andrew";
    sessionPath = [ "${homeDirectory}/.cargo/bin" ];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs  ; [
    htop
    xwayland
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
    aerc
    wofi
    rofi
    bat
    wl-clipboard
    ripgrep
    playerctl
    pamixer
    tree
    swaylock
    swayidle
    lm_sensors
    fd
    xdg_utils
    libreoffice
    lf
    borgbackup
    prettyping
    darktable
    gitAndTools.git-open
  ];

  programs = {
    home-manager.enable = true;

    alacritty = import ./alacritty.nix pkgs;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNixDirenvIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ssh = import ./ssh.nix;

    git = import ./git.nix pkgs;

    firefox = import ./firefox.nix pkgs;

    mako = import ./mako.nix;

    neovim = import ./neovim.nix pkgs;

    newsboat = import ./newsboat.nix;

    taskwarrior = {
      enable = true;
    };

    tmux = import ./tmux.nix;

    waybar = import ./waybar.nix { inherit pkgs status-bar; };

    zathura = import ./zathura.nix;

    zsh = import ./zsh.nix pkgs;
  };

  wayland.windowManager.sway = import ./sway.nix { inherit pkgs sway-scripts; };

  services = {
    syncthing = {
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
