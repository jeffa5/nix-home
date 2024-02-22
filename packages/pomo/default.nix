{pkgs}:
pkgs.writeShellScriptBin "pomo" ''
  state_file="$HOME/.local/share/pomo"
  flock -x $state_file ${./pomo.sh} $@
''
