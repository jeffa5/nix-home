pkgs:
pkgs.writeShellScriptBin "app-launcher" ''
  #!${pkgs.bash}/bin/bash

  pgrep wofi && pkill wofi && exit 0

  error=$(${pkgs.wofi}/bin/wofi --show run 2>&1)

  if [ -n "$error" ]; then
      ${pkgs.libnotify}/bin/notify-send --urgency=critical "Wofi" "$error"
  fi
''
