pkgs:
let
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

  dark = {
    # Colors (Gruvbox dark)
    primary = {
      background = "0x282828";
      foreground = "0xebdbb2";
    };
    normal = {
      black = "0x282828";
      red = "0xcc241d";
      green = "0x98971a";
      yellow = "0xd79921";
      blue = "0x458588";
      magenta = "0xb16286";
      cyan = "0x689d6a";
      white = "0xa89984";
    };
    bright = {
      black = "0x928374";
      red = "0xfb4934";
      green = "0xb8bb26";
      yellow = "0xfabd2f";
      blue = "0x83a598";
      magenta = "0xd3869b";
      cyan = "0x8ec07c";
      white = "0xebdbb2";
    };
  };
in
{
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
      size = 13.0;
    };

    draw_bold_text_with_bright_colors = true;

    colors = light;

    mouse = {
      hints = {
        launcher = "${pkgs.xdg-utils}/bin/xdg-open";
      };
    };
  };
}
