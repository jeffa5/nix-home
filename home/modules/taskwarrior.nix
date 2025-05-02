{pkgs, ...}: {
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    colorTheme = "light-256";
  };
  home.packages = [
    pkgs.tasksh
    pkgs.taskwarrior-tui
  ];
}
