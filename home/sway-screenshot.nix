pkgs:
let
  rofi = "${pkgs.rofi}/bin/rofi";
  slurp = "${pkgs.slurp}/bin/slurp";
  grim = "${pkgs.grim}/bin/grim";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  convert = "${pkgs.imagemagick}/bin/convert";
in
''
  #!${pkgs.stdenv.shell}

  # if rofi is running, kill it
  pgrep rofi && pkill rofi && exit 0

  inputs=$(printf "Focused output\nAll outputs\nRegion\nFocused window\nWindow\nColour Picker")

  selection=$(echo "''$inputs" | ${rofi} -dmenu -p "screenshot" -i)

  PICTURE_DIR="$HOME/Pictures/screenshots/"
  PICTURE_FILE="$PICTURE_DIR$(date +'%Y-%m-%d-%H%M%S_screenshot.png')"

  destination() {
      printf "File\nClipboard" | ${rofi} -dmenu -p "Destination" -i
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
''
