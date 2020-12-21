{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "andrew";
  home.homeDirectory = "/home/andrew";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs  ; [
    htop
    waybar
    mako
    xwayland
    alacritty
    zathura
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
    tmux
    aerc
    newsboat
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
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNixDirenvIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
      profiles = {
        andrew = {
          settings = {
            "browser.startup.page" = 3;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;
          };
        };
      };
    };

    neovim = import ./home/neovim.nix pkgs;

    zsh = import ./home/zsh.nix pkgs;
  };

  wayland.windowManager.sway = import ./home/sway.nix pkgs;

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
