{
  pkgs,
  lib,
  ...
}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${lib.getExe pkgs.alacritty} -e";
        inner-pad = 8;
      };
      colors = {
        background = "fbf1c7ff";
        text = "3c3836ff";
        match = "cc241dff";
        selection = "98971aff";
        selection-text = "3c3836ff";
        selection-match = "cc241dff";
        border = "7c6f64ff";
      };
    };
  };
}
