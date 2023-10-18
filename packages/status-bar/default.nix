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

  productivity-timer-status = pkgs.writeShellScriptBin "productivity-timer-status" ''
    socket=/tmp/owork.sock

    send_to_pomo() {
        [ -e $socket ] && echo "$1" | nc -U $socket
    }

    state=$(send_to_pomo "get/state")
    time=$(send_to_pomo "get/time")
    sessions_complete=$(send_to_pomo "get/completed")
    paused=$(send_to_pomo "get/paused")
    percent=$(send_to_pomo "get/percentage")

    if [ -z "$state" ]; then
        exit 1
    fi

    pomo="⌛$state $time $sessions_complete"
    if [ $paused == "true" ]; then
        if [ $state == "Idle" ]; then
            pomo="⌛ $state"
        fi
    else
        if [ $percent -ge 80 ]; then
            colour="#b8bb26"
        elif [ $percent -ge 60 ]; then
            colour="#98971a"
        elif [ $percent -ge 40 ]; then
            colour="#fabd2f"
        elif [ $percent -ge 20 ]; then
            colour="#d79921"
        elif [ $percent -ge 10 ]; then
            colour="#fb4934"
        else
            colour="#cc241d"
        fi
    fi

    echo $pomo
  '';
}
