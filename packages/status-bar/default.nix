pkgs: let
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  pomo = pkgs.lib.getExe (import ../pomo {inherit pkgs;});
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

  pomo-status = pkgs.writeShellScriptBin "pomo-status" ''
    ${pomo} notify

    state=$(${pomo} cycle)
    time=$(${pomo} remaining +%M:%S)
    sessions_complete=$(${pomo} count)
    paused=false
    percent=$(${pomo} percent)

    if [ -z "$state" ]; then
        exit 1
    fi

    text="⌛$state $time $sessions_complete"
    if [[ "$state" = "idle" ]]; then
      text="⌛$state"
      class=idle
    else
      if [[ $(${pomo} remaining) -lt 0 ]]; then
        class=finished
      else
        class=running
      fi
    fi

    echo $text
    echo
    echo $class
  '';
}
