{
  pkgs,
  lib,
  ...
}: let
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
          "custom/mediaplayer"
          "custom/pomo"
          "systemd-failed-units"
          "pulseaudio"
          "backlight"
          "bluetooth"
          "network"
          "battery"
          "sway/language"
          "custom/notifications"
          "clock"
          "tray"
        ];
        modules = {
          "sway/workspaces" = {
            disable-scroll = true;
          };
          "sway/language" = {
            on-click = "${lib.getExe' pkgs.sway "swaymsg"} -t command input type:keyboard xkb_switch_layout next";
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = " {volume}%";
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
          systemd-failed-units = { };
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
            format = "{ifname}";
            format-ethernet = "Eth";
            format-wifi = "🛜 {essid} ({signalStrength}%)";
            format-disconnected = "Disconnected";
          };
          bluetooth = {
            format = " {status}";
            format-disabled = ""; # an empty format will hide the module
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} 🔋{device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-connected-battery = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t🔋{device_battery_percentage}%\t{device_address}";
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
          "custom/pomo" = {
            format = "{}";
            interval = 1;
            exec = "${pkgs.status-bar.pomo-status}/bin/pomo-status";
            on-click = "${pkgs.sway-scripts.pomo-timer}/bin/pomo-timer";
          };
          "custom/mediaplayer" = {
            format = "{}";
            interval = 1;
            exec = "${pkgs.status-bar.mediaplayer}/bin/bar-mediaplayer";
            exec-if = "${lib.getExe pkgs.playerctl} status &> /dev/null";
            escape = true;
            on-click = "${lib.getExe pkgs.playerctl} play-pause";
          };
          "custom/notifications" = {
            format = "{}";
            return-type = "json";
            interval = 1;
            exec = "${pkgs.status-bar.notifications}/bin/bar-notifications";
            on-click = "${pkgs.status-bar.toggle-dnd}/bin/bar-toggle-dnd";
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
      #bluetooth,
      #network,
      #pulseaudio,
      #systemd-failed-units,
      #mode,
      #custom-pomo,
      #custom-mediaplayer,
      #custom-notifications,
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

      #custom-pomo.running {
        background: #98971a;
      }
      #custom-pomo.finished {
        background: #cc241d;
      }
    '';
  };
  wayland.windowManager.sway.config.bars = [
    {
      command = lib.getExe pkgs.waybar;
    }
  ];
}
