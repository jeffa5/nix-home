{
  pkgs,
  lib,
  ...
}: {
  xdg.mimeApps.defaultApplications."x-scheme-handler/terminal" = ["foot.desktop"];
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=12";
      };
      colors = {
        # Colors (Gruvbox light)
        background = "fbf1c7";
        foreground = "3c3836";
        regular0 = "fbf1c7";
        regular1 = "cc241d";
        regular2 = "98971a";
        regular3 = "d79921";
        regular4 = "458588";
        regular5 = "b16286";
        regular6 = "689d6a";
        regular7 = "7c6f64";
        bright0 = "928374";
        bright1 = "9d0006";
        bright2 = "79740e";
        bright3 = "b57614";
        bright4 = "076678";
        bright5 = "8f3f71";
        bright6 = "427b58";
        bright7 = "3c3836";
      };
    };
  };

  programs.fuzzel.settings.main.terminal = "${lib.getExe pkgs.foot} -e";
  wayland.windowManager.sway.config.terminal = lib.getExe pkgs.foot;
}
