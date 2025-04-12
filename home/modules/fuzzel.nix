{...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        inner-pad = 8;
        dpi-aware = true;
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
