{pkgs, ...}: let
  pomo =
    pkgs.writeShellScriptBin "pomo" (builtins.readFile ./pomo.sh);
in {
  home.packages = [pomo];
}
