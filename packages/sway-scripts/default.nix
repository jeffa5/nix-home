{
  pkgs,
  lib,
}: let
  pomo = pkgs.lib.getExe (import ../pomo {inherit pkgs;});
in {
  app-launcher = pkgs.writeShellScriptBin "app-launcher" ''
    pgrep fuzzel && pkill fuzzel && exit 0

    ${lib.getExe pkgs.fuzzel}
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
          ${notify-send} --app-name screenshot "Colour Picker" "$colour"
          ;;
      esac
    '';

  pomo-timer = pkgs.writeShellScriptBin "pomo-timer" ''
    pgrep wofi && pkill wofi && exit 0

    inputs="Start session\nReset timer\nRestart session\nSkip session"

    selection=$(echo -e "$inputs" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Timer" --insensitive --lines 10)

    case $selection in
      "Start session")
        ${pomo} start
        ;;
      "Reset timer")
        ${pomo} reset
        ;;
      "Restart session")
        ${pomo} restart
        ;;
      "Skip session")
        ${pomo} skip
        ;;
      *) ;;
    esac
  '';

  pomo-notify = pkgs.writeShellScriptBin "pomo-notify" ''
    pgrep waytext && pkill waytext

    case "$1" in
    "idle")
        text="Idle"
        ;;
    "work")
        text="Start work"
        ;;
    "short")
        text="Take a short break"
        ;;
    "long")
        text="Take a long break"
        ;;
    esac

    ${pkgs.waytext}/bin/waytext -t "$text"
  '';

  bw-menu = let
    rbw = pkgs.lib.getExe' pkgs.rbw "rbw";
    wofi = pkgs.lib.getExe pkgs.wofi;
    wl-copy = pkgs.lib.getExe' pkgs.wl-clipboard "wl-copy";
    notify-send = pkgs.lib.getExe' pkgs.libnotify "notify-send";
  in
    pkgs.writeShellScriptBin "bw-menu" ''
      ${rbw} unlocked &> /dev/null || ${rbw} unlock || exit 1

      item=$(${rbw} list | ${wofi} --dmenu --matching fuzzy --insensitive --prompt "Select an entry")
      if [[ -z "$item" ]]; then
        exit 1
      fi

      field=$(echo -e "Username\nPassword" | ${wofi} --dmenu --matching fuzzy --insensitive --prompt "Select a field")
      if [[ -z "$field" ]]; then
        exit 1
      fi

      ${rbw} get "$item" --field "$field" | ${wl-copy}

      ${notify-send} --app-name bw-menu "Copied $field to clipboard"
    '';
}
