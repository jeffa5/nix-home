{
  pkgs,
  lib,
  ...
}: let
  light = {
    # Colors (Gruvbox light)
    primary = {
      # hard contrast: background = '#f9f5d7'
      background = "#fbf1c7";
      # soft contrast: background = '#f2e5bc'
      foreground = "#3c3836";
    };

    normal = {
      black = "#fbf1c7";
      red = "#cc241d";
      green = "#98971a";
      yellow = "#d79921";
      blue = "#458588";
      magenta = "#b16286";
      cyan = "#689d6a";
      white = "#7c6f64";
    };

    bright = {
      black = "#928374";
      red = "#9d0006";
      green = "#79740e";
      yellow = "#b57614";
      blue = "#076678";
      magenta = "#8f3f71";
      cyan = "#427b58";
      white = "#3c3836";
    };
  };
in {
  xdg.mimeApps.defaultApplications."x-scheme-handler/terminal" = ["Alacritty.desktop"];
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Hack Nerd Font";
        };
        bold = {
          family = "Hack Nerd Font";
        };
        italic = {
          family = "Hack Nerd Font";
        };
        size = 12.0;
      };

      colors =
        light
        // {
          draw_bold_text_with_bright_colors = true;
        };

      env = {
        EDITOR = "nvim";
      };
    };
  };

  programs.fuzzel.settings.main.terminal = "${lib.getExe pkgs.alacritty} -e";
  wayland.windowManager.sway.config.terminal = lib.getExe pkgs.alacritty;
}
