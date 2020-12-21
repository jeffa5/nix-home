{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "andrew";
  home.homeDirectory = "/home/andrew";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs  ; [
    htop
    waybar
    xwayland
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
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

    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      delta.enable = true;
      userEmail = "dev@jeffas.io";
      userName = "Andrew Jeffery";
      extraConfig = {
        pull = {
          ff = "only";
        };
      };
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

    mako = {
      enable = true;
      backgroundColor = "#282828";
      # borderColor = ""
      borderSize = 4;
      defaultTimeout = 5000;
      font = "hack 12";
      height = 200;
      textColor = "#ebdbb2";
      width = 400;
      extraConfig = ''
        [hidden]
        border-color=#83a598

        [urgency=low]
        border-color=#b8bb26

        [urgency=normal]
        border-color=#fabd2f

        [urgency=high]
        border-color=#fb4934
      '';
    };

    neovim = import ./neovim.nix pkgs;

    tmux = import ./tmux.nix;

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
