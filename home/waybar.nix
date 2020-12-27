{ pkgs, status-bar }:
{
  enable = true;
  settings = [
    {
      height = 21;
      position = "bottom";
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-right = [ "custom/spotify" "pulseaudio" "backlight" "memory" "cpu" "network" "battery" "clock" "tray" ];
      modules = {
        "sway/workspaces" = {
          disable-scroll = true;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = " {volume}%";
          format-muted = "";
          format-icons = {
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" ];
          };
          scroll-step = 5;
        };
        backlight = {
          format = " {percent}%";
          exec-if = "${status-bar}/bin/backlight";
        };
        memory = {
          format = " {}%";
          states = {
            warning = 50;
            critical = 80;
          };
        };
        cpu = {
          format = " {usage}%";
          states = {
            warning = 50;
            critical = 80;
          };
        };
        network = {
          interval = 5;
          format-ethernet = " {bandwidthDownBits}  {bandwidthUpBits}";
          format-wifi = " {signalStrength}%  {bandwidthDownBits}  {bandwidthUpBits}";
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          states = {
            warning = 50;
            critical = 30;
          };
        };
        clock = {
          interval = 1;
          format = " {:%H:%M:%S  %a %d/%m/%Y}";
        };
        "custom/spotify" = {
          format = "{}";
          interval = 1;
          exec = "${status-bar}/bin/mediaplayer";
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
      font-family: Hack Nerd Font, Helvetica, Arial, sans-serif;
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: #1d2021;
      color: #ebdbb2;
      transition-property: background, background-color;
      transition-duration: 0.5s;
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    #workspaces button {
      padding: 0 5px;
      margin: 1px;
      background: #282828;
      color: #ebdbb2;
    }

    #workspaces button:hover {
      box-shadow: inherit;
      text-shadow: inherit;
    }

    #workspaces button.focused {
      background: #98971a;
    }

    #workspaces button.visible:not(.focused) {
      background: #458588;
    }

    #workspaces button.urgent {
      background: #cc241d;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #backlight,
    #network,
    #pulseaudio,
    #mode,
    #custom-spotify {
      padding: 0 5px;
      margin: 0 3px;
      background: #282828;
      color: #ebdbb2;
    }

    #battery {
      background: #282828;
    }

    #battery.discharging {
      background: #282828;
    }

    #battery.discharging.warning {
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

    #battery.full {
      background: #98971a;
    }

    #cpu {
      background: #282828;
    }

    #cpu.warning {
      background: #d65d0e;
    }

    #cpu.critical {
      background: #cc241d;
    }

    #memory {
      background: #282828;
    }

    #memory.warning {
      background: #d65d0e;
    }

    #memory.critical {
      background: #cc241d;
    }

    #backlight {
      background: #282828;
    }

    #network {
      background: #282828;
    }

    #network.disconnected {
      background: #f53c3c;
    }

    #pulseaudio {
      background: #282828;
    }

    #custom-spotify {
      background: #282828;
    }'';
}
