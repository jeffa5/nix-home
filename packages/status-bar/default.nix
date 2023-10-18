pkgs: let
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in {
  backlight = pkgs.writeShellScriptBin "bar-backlight" ''
    [ "$1" -gt "0" ]
  '';
  mediaplayer = pkgs.writeShellScriptBin "bar-mediaplayer" ''
    title=$(${playerctl} --player spotify metadata title)
    if [ $? != 0 ] || [ -z "$title" ]; then
      exit 0
    fi

    artist=$(${playerctl} --player spotify metadata artist)
    if [ $? != 0 ]; then
      exit 0
    fi

    status=$(${playerctl} --player spotify status)
    if [ $status == "Paused" ]; then
      icon="⏸"
      class="paused"
    elif [ $status == "Playing" ]; then
      icon="⏵"
      class="playing"
    fi

    echo "$icon $title - $artist"
  '';
}
