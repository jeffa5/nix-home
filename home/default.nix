{ status-bar }:
{ config, pkgs, ... }:

{
  imports = [ ./aerc.nix ./swaylock.nix ./xkb.nix ];

  nixpkgs.config.allowUnfree = true;

  home.username = "andrew";
  home.homeDirectory = "/home/andrew";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs  ; [
    htop
    xwayland
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
    aerc
    syncthing
    wofi
    rofi
    rofi-calc
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
    taskwarrior
    lf
    borgbackup
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

    tmux = import ./tmux.nix;

    waybar = import ./waybar.nix status-bar;

    zathura = import ./zathura.nix;

    zsh = import ./zsh.nix pkgs;
  };

  wayland.windowManager.sway = import ./sway.nix pkgs;

  services = {
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
