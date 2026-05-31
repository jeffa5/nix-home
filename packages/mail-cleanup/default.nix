{
  pkgs,
  lib,
}: let
  runtimePath = lib.makeBinPath (with pkgs; [
    mu
    jq
    fzf
    coreutils
    gawk
    findutils
    python3
  ]);
in
  pkgs.writeShellScriptBin "mail-cleanup" ''
    export PATH=${runtimePath}:$PATH
    exec ${./mail-cleanup.sh} "$@"
  ''
