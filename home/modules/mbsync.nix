{
  pkgs,
  lib,
  ...
}: let
  mu = lib.getExe pkgs.mu;
  muUpdate = pkgs.writeShellScriptBin "mu-update" ''
    ${mu} index
    ${pkgs.lib.getExe pkgs.maildir-rank-addr} --maildir ~/mail --outputpath ~/contacts/list --template '{{.Name}} {{.Address}}'
  '';
in {
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    postExec = lib.getExe muUpdate;
  };
}
