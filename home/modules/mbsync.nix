{
  pkgs,
  lib,
  ...
}: let
  mu = lib.getExe pkgs.mu;
  muUpdate = pkgs.writeShellScriptBin "mu-update" ''
    ${mu} index
    ${mu} cfind > ~/contacts/list
  '';
in {
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    postExec = lib.getExe muUpdate;
  };
}
