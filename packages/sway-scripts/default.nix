pkgs: {
  app-launcher = pkgs.writeShellScriptBin "app-launcher" ''
    pgrep wofi && pkill wofi && exit 0

    error=$(${pkgs.wofi}/bin/wofi --show run 2>&1)

    if [ -n "$error" ]; then
        ${pkgs.libnotify}/bin/notify-send --urgency=critical "Wofi" "$error"
    fi
  '';

  lockscreen = pkgs.writeShellScriptBin "sway-lockscreen" ''
    ${pkgs.swayidle}/bin/swayidle \
      timeout 60 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
      resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
      timeout 300 '${pkgs.systemd}/bin/systemctl suspend' \
      after-resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' &

    pid=$!

    ${pkgs.swaylock}/bin/swaylock

    kill $pid
  '';

  screenshot = let
    wofi = "${pkgs.wofi}/bin/wofi";
    slurp = "${pkgs.slurp}/bin/slurp";
    grim = "${pkgs.grim}/bin/grim";
    notify-send = "${pkgs.libnotify}/bin/notify-send";
    grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
    convert = "${pkgs.imagemagick}/bin/convert";
  in
    pkgs.writeShellScriptBin "sway-screenshot" ''
      # if wofi is running, kill it
      pgrep wofi && pkill wofi && exit 0

      inputs=$(printf "Focused output\nAll outputs\nRegion\nFocused window\nWindow\nColour Picker")

      selection=$(echo "''$inputs" | ${wofi} --dmenu -p "screenshot" -i)

      PICTURE_DIR="$HOME/Pictures/screenshots/"
      PICTURE_FILE="$PICTURE_DIR$(date +'%Y-%m-%d-%H%M%S_screenshot.png')"

      destination() {
          printf "File\nClipboard" | ${wofi} --dmenu -p "Destination" -i
      }

      case "$selection" in
      "Focused output")
          dest=$(destination)
          case "$dest" in
          "File")
              ${grimshot} --notify save output "$PICTURE_FILE"
              ;;
          "Clipboard")
              ${grimshot} --notify copy output
              ;;
          esac
          ;;

      "All outputs")
          dest=$(destination)
          case "$dest" in
          "File")
              ${grimshot} --notify save screen "$PICTURE_FILE"
              ;;
          "Clipboard")
              ${grimshot} --notify copy screen
              ;;
          esac
          ;;

      "Region")
          dest=$(destination)
          case "$dest" in
          "File")
              ${grimshot} --notify save area "$PICTURE_FILE"
              ;;
          "Clipboard")
              ${grimshot} --notify copy area
              ;;
          esac
          ;;

      "Focused window")
          dest=$(destination)
          case "$dest" in
          "File")
              ${grimshot} --notify save active "$PICTURE_FILE"
              ;;
          "Clipboard")
              ${grimshot} --notify copy active
              ;;
          esac
          ;;

      "Window")
          dest=$(destination)
          case "$dest" in
          "File")
              ${grimshot} --notify save window "$PICTURE_FILE"
              ;;
          "Clipboard")
              ${grimshot} --notify copy window
              ;;
          esac
          ;;

      "Colour Picker")
          colour=$(${grim} -g "$(${slurp} -p)" -t ppm - | ${convert} - -format '%[pixel:p{0,0}]' txt:- | sed -n 2p | awk '{ print $3 }')
          ${notify-send} "Colour Picker" "$colour"
          ;;
      esac
    '';

  productivity-timer = pkgs.writeShellScriptBin "productivity-timer" ''
    pgrep wofi && pkill wofi && exit 0

    inputs="Toggle pause\nReset timer\nRestart session\nSkip session"

    send_to_server() {
      echo "$1" | nc -U /tmp/owork.sock
    }

    selection=$(echo -e "$inputs" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Timer" --insensitive --lines 10)

    case $selection in
      "Toggle pause")
        send_to_server "set/toggle"
        ;;
      "Reset timer")
        send_to_server "set/reset"
        ;;
      "Restart session")
        send_to_server "set/restart"
        ;;
      "Skip session")
        send_to_server "set/skip"
        ;;
      *) ;;
    esac
  '';

  productivity-timer-notify = pkgs.writeShellScriptBin "productivity-timer-notify" ''
    pgrep waytext && pkill waytext

    case "$1" in
    "Idle")
        text="Idle"
        ;;
    "Work")
        text="Start work"
        ;;
    "Short")
        text="Take a short break"
        ;;
    "Long")
        text="Take a long break"
        ;;
    esac

    ${pkgs.waytext} -t "$text"
  '';
}
