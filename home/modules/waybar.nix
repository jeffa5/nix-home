{pkgs, ...}: let
  productivity-timer = pkgs.writeScriptBin "productivity-timer" ''
    #!${pkgs.bash}/bin/bash

    pgrep wofi && pkill wofi && exit 0

    inputs="Toggle pause\nReset timer\nRestart session\nSkip session"

    send_to_server() {
      echo "$1" | nc -U /tmp/owork.sock
    }

    selection=$(echo -e "$inputs" | ${pkgs.wofi}/bin/wofi --dmenu --cache-file "/tmp/wofi-owork-cache" --prompt "Timer" --insensitive --lines 5 && rm /tmp/wofi-owork-cache)

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
  productivity-timer-status = pkgs.writeScriptBin "productivity-timer-status" ''
    #!${pkgs.stdenv.shell}

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

    if [ $paused == "true" ]; then
        if [ $state == "Idle" ]; then
            pomo=" $state"
        else
            pomo=" $state $time $sessions_complete"
        fi
    else
        pomo="$state $time $sessions_complete"
        if [ $percent -ge 80 ]; then
            pomo=" $pomo"
            colour="#b8bb26"
        elif [ $percent -ge 60 ]; then
            pomo=" $pomo"
            colour="#98971a"
        elif [ $percent -ge 40 ]; then
            pomo=" $pomo"
            colour="#fabd2f"
        elif [ $percent -ge 20 ]; then
            pomo=" $pomo"
            colour="#d79921"
        elif [ $percent -ge 10 ]; then
            pomo=" $pomo"
            colour="#fb4934"
        else
            pomo=" $pomo"
            colour="#cc241d"
        fi
    fi

    echo $pomo
  '';
  background = "#fbf1c7";
  background_light = "#ebdbb2";
  foreground = "#3c3836";
in {
  programs.waybar = {
    enable = true;
    settings = [
      {
        height = 21;
        position = "bottom";
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-right = [
          "custom/spotify"
          "custom/owork"
          "pulseaudio"
          "backlight"
          "memory"
          "cpu"
          # "temperature"
          "network"
          "battery"
          "sway/language"
          "clock"
          "tray"
        ];
        modules = {
          "sway/workspaces" = {
            disable-scroll = true;
          };
          "sway/language" = {
            on-click = "${pkgs.sway}/bin/swaymsg -t command input '*' xkb_switch_layout next";
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "BT {volume}%";
            format-muted = "🔇";
            format-icons = {
              headphones = "H";
              handsfree = "H";
              headset = "H";
              phone = "P";
              portable = "P";
              car = "C";
              default = ["Vol"];
            };
            scroll-step = 5;
          };
          backlight = {
            format = "☼ {percent}%";
            exec-if = "${pkgs.status-bar.backlight}/bin/bar-backlight";
          };
          memory = {
            format = "Mem {}%";
            states = {
              warning = 50;
              critical = 80;
            };
          };
          cpu = {
            format = "Cpu {usage}%";
            states = {
              warning = 50;
              critical = 80;
            };
          };
          temperature = {
            critical-threshold = 70;
            format-critical = "🌡 {temperatureC}°C";
            format = "🌡 {temperatureC}°C";
          };
          network = {
            interval = 5;
            format-ethernet = "↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
            format-wifi = "🛜 {signalStrength}% ↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
          };
          battery = {
            format = "{icon} {capacity}%";
            format-charging = "🔌 {capacity}%";
            format-icons = ["🔋"];
            states = {
              warning = 50;
              critical = 30;
            };
          };
          clock = {
            interval = 1;
            format = "🕒 {:%H:%M:%S 📅 %a %d/%m/%Y}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
          };
          tray = {
            spacing = 8;
          };
          "custom/owork" = {
            format = "{}";
            interval = 1;
            exec = "${productivity-timer-status}/bin/productivity-timer-status";
            exec-if = "pgrep owork";
            on-click = "${productivity-timer}/bin/productivity-timer";
          };
          "custom/spotify" = {
            format = "{}";
            interval = 1;
            exec = "${pkgs.status-bar.mediaplayer}/bin/bar-mediaplayer";
            exec-if = "${pkgs.playerctl}/bin/playerctl --player spotify status &> /dev/null";
            escape = true;
            on-click = "${pkgs.playerctl}/bin/playerctl --player spotify play-pause";
          };
        };
      }
    ];
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: ${background};
        color: ${foreground};
        transition-property: background, background-color;
        transition-duration: 0.5s;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button {
        padding: 0 5px;
        margin: 1px;
        background: ${background_light};
        color: ${foreground};
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }

      #workspaces button.focused,
      #battery.full {
        background: #98971a;
      }

      #workspaces button.visible:not(.focused) {
        background: #458588;
      }

      #clock,
      #battery,
      #battery.discharging,
      #language,
      #cpu,
      #temperature,
      #memory,
      #backlight,
      #network,
      #pulseaudio,
      #mode,
      #custom-owork,
      #custom-spotify,
      #tray {
        padding: 0 5px;
        margin: 0 3px;
        background: ${background_light};
        color: ${foreground};
      }

      #battery.discharging.warning,
      #cpu.warning,
      #memory.warning {
        background: #d65d0e;
      }

      #battery.discharging.critical {
        background: #cc241d;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #cpu.critical,
      #workspaces button.urgent,
      #temperature.critical,
      #memory.critical {
        background: #cc241d;
      }

      #network.disconnected {
        background: #f53c3c;
      }
    '';
  };
}
