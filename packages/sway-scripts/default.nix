{
  pkgs,
  lib,
}: let
  pomo = pkgs.lib.getExe (import ../pomo {inherit pkgs;});
  menu = "${lib.getExe pkgs.fuzzel} --dmenu";
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
in {
  app-launcher = pkgs.writeShellScriptBin "app-launcher" ''
    pgrep fuzzel && pkill fuzzel && exit 0

    ${lib.getExe pkgs.fuzzel}
  '';

  file-launcher = pkgs.writeShellScriptBin "file-launcher" ''
    pgrep fuzzel && pkill fuzzel && exit 0

    ${lib.getExe' pkgs.findutils "find"} Cloud Downloads Pictures -type f | ${menu} --width 100 | ${lib.getExe' pkgs.coreutils "tr"} '\n' '\0' | ${lib.getExe' pkgs.findutils "xargs"} --no-run-if-empty --null ${lib.getExe' pkgs.xdg-utils "xdg-open"}
  '';

  lockscreen = pkgs.writeShellScriptBin "sway-lockscreen" ''
    ${lib.getExe pkgs.swayidle} \
      timeout 60 '${swaymsg} "output * dpms off"' \
      resume '${swaymsg} "output * dpms on"' \
      timeout 300 '${lib.getExe' pkgs.systemd "systemctl"} hybrid-sleep' \
      after-resume '${swaymsg} "output * dpms on"' &

    pid=$!

    ${lib.getExe pkgs.swaylock}

    kill $pid
  '';

  screenshot = let
    slurp = lib.getExe pkgs.slurp;
    grim = lib.getExe pkgs.grim;
    notify-send = lib.getExe' pkgs.libnotify "notify-send";
    grimshot = lib.getExe pkgs.sway-contrib.grimshot;
    convert = lib.getExe' pkgs.imagemagick "convert";
  in
    pkgs.writeShellScriptBin "sway-screenshot" ''
      # if fuzzel is running, kill it
      pgrep fuzzel && pkill fuzzel && exit 0

      inputs=$(printf "Focused output\nAll outputs\nRegion\nFocused window\nWindow\nColour Picker")

      selection=$(echo "''$inputs" | ${menu} --lines 6 --prompt "screenshot> ")

      PICTURE_DIR="$HOME/Pictures/screenshots/"
      PICTURE_FILE="$PICTURE_DIR$(date +'%Y-%m-%d-%H%M%S_screenshot.png')"

      mkdir -p $PICTURE_DIR

      destination() {
          printf "File\nClipboard" | ${menu} --lines 2 --prompt "destination> "
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
    pgrep fuzzel && pkill fuzzel && exit 0

    inputs="Start session\nReset timer\nRestart session\nSkip session"

    selection=$(echo -e "$inputs" | ${menu} --lines 4 --prompt "timer> ")

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

    ${lib.getExe pkgs.waytext} -t "$text"
  '';

  bw-menu = let
    rbw = pkgs.lib.getExe' pkgs.rbw "rbw";
    wl-copy = pkgs.lib.getExe' pkgs.wl-clipboard "wl-copy";
    notify-send = pkgs.lib.getExe' pkgs.libnotify "notify-send";
  in
    pkgs.writeShellScriptBin "bw-menu" ''
      ${rbw} unlocked &> /dev/null || ${rbw} unlock || exit 1

      item=$(${rbw} list | ${menu} --prompt "entry> ")
      if [[ -z "$item" ]]; then
        exit 1
      fi

      field=$(echo -e "Username\nPassword" | ${menu} --prompt "field> ")
      if [[ -z "$field" ]]; then
        exit 1
      fi

      ${rbw} get "$item" --field "$field" | ${wl-copy}

      ${notify-send} --app-name bw-menu "Copied $field to clipboard"
    '';
}
