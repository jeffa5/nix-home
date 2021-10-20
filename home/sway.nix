{ pkgs, sway-scripts }:
let
  normal_bg = "#282828";
  normal_fg = "#ebdbb2";
  focus_bg = "#98971a";
  inactive_bg = "#282828";
  urgent_bg = "#cc241d";

  sway-lockscreen = pkgs.writeScriptBin "sway-lockscreen" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.swayidle}/bin/swayidle \
      timeout 60 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
      resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
      timeout 300 '${pkgs.systemd}/bin/systemctl suspend' \
      after-resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' &

    pid=$!

    ${pkgs.swaylock}/bin/swaylock

    kill $pid
  '';

  sway-screenshot = pkgs.writeScriptBin "sway-screenshot" (import ./sway-screenshot.nix pkgs);

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
in
rec {
  enable = true;
  extraConfig = ''
    set $workspace1 1 
    set $workspace2 2 
    set $workspace3 3 
    set $workspace4 4
    set $workspace5 5
    set $workspace6 6
    set $workspace7 7
    set $workspace8 8 
    set $workspace9 9 
    set $workspace10 10 

    set $mode_system System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (p) shutdown
    mode "$mode_system" {
        bindsym l exec --no-startup-id $locker, mode "default"
        bindsym e exit, mode "default"
        bindsym s exec --no-startup-id $locker && ${pkgs.systemd}/bin/systemctl suspend, mode "default"
        bindsym h exec --no-startup-id $locker && ${pkgs.systemd}/bin/systemctl hybrid-sleep, mode "default"
        bindsym r exec --no-startup-id ${pkgs.systemd}/bin/systemctl reboot, mode "default"
        bindsym p exec --no-startup-id ${pkgs.systemd}/bin/systemctl poweroff -i, mode "default"
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }

    # This ensures all user units started after the command (not those already running) set the variables
    exec systemctl --user import-environment
  '';

  config = {
    modifier = "Mod4";

    bars = [
      {
        command = "${pkgs.waybar}/bin/waybar";
      }
    ];

    colors = {
      focused = {
        background = focus_bg;
        border = focus_bg;
        childBorder = focus_bg;
        indicator = focus_bg;
        text = normal_fg;
      };
      focusedInactive = {
        background = inactive_bg;
        border = inactive_bg;
        childBorder = inactive_bg;
        indicator = inactive_bg;
        text = normal_fg;
      };
      unfocused = {
        background = normal_bg;
        border = normal_bg;
        childBorder = normal_bg;
        indicator = normal_bg;
        text = normal_fg;
      };
      urgent = {
        background = normal_bg;
        border = urgent_bg;
        childBorder = urgent_bg;
        indicator = urgent_bg;
        text = urgent_bg;
      };
    };

    gaps = {
      inner = 10;
    };

    input = {
      "*" = {
        xkb_layout = "iso-uk-colemak-dh,gb";
        xkb_options = "grp:alt_shift_toggle";
      };
      "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" = {
        middle_emulation = "enabled";
        tap = "enabled";
        natural_scroll = "enabled";
      };
    };

    output = {
      "*" = { bg = "#458588 solid_color"; };
      "eDP-1" = {
        position = "1080 2160";
      };
      "HDMI-A-1" = {
        position = "0 1080";
      };
      "DP-1" = {
        position = "0 0";
        scale = "1.5";
      };
      "DP-2" = {
        position = "1920 1080";
      };
    };

    keybindings = pkgs.lib.mkOptionDefault {
      "${config.modifier}+q" = "kill";
      "${config.modifier}+Shift+r" = "reload";
      "${config.modifier}+1" = "workspace $workspace1";
      "${config.modifier}+2" = "workspace $workspace2";
      "${config.modifier}+3" = "workspace $workspace3";
      "${config.modifier}+4" = "workspace $workspace4";
      "${config.modifier}+5" = "workspace $workspace5";
      "${config.modifier}+6" = "workspace $workspace6";
      "${config.modifier}+7" = "workspace $workspace7";
      "${config.modifier}+8" = "workspace $workspace8";
      "${config.modifier}+9" = "workspace $workspace9";
      "${config.modifier}+0" = "workspace $workspace10";
      "${config.modifier}+Shift+1" = "move container to workspace $workspace1";
      "${config.modifier}+Shift+2" = "move container to workspace $workspace2";
      "${config.modifier}+Shift+3" = "move container to workspace $workspace3";
      "${config.modifier}+Shift+4" = "move container to workspace $workspace4";
      "${config.modifier}+Shift+5" = "move container to workspace $workspace5";
      "${config.modifier}+Shift+6" = "move container to workspace $workspace6";
      "${config.modifier}+Shift+7" = "move container to workspace $workspace7";
      "${config.modifier}+Shift+8" = "move container to workspace $workspace8";
      "${config.modifier}+Shift+9" = "move container to workspace $workspace9";
      "${config.modifier}+Shift+0" = "move container to workspace $workspace10";
      "${config.modifier}+space" = "exec ${sway-scripts}/bin/wofi";
      "${config.modifier}+t" = "exec ${productivity-timer}/bin/productivity-timer";
      "${config.modifier}+Alt+f" = "exec --no-startup-id swaymsg 'workspace $workspace1; exec ${pkgs.firefox}/bin/firefox'";
      "${config.modifier}+Alt+m" = "exec --no-startup-id swaymsg 'workspace $workspace9; exec ${pkgs.thunderbird}/bin/thunderbird'";
      "${config.modifier}+Alt+s" = "exec --no-startup-id swaymsg 'workspace $workspace10; exec ${pkgs.spotify}/bin/spotify'";
      "${config.modifier}+p" = "exec ${sway-screenshot}/bin/sway-screenshot";
      "${config.modifier}+Shift+y" = "move workspace to output left";
      "${config.modifier}+Shift+u" = "move workspace to output down";
      "${config.modifier}+Shift+i" = "move workspace to output up";
      "${config.modifier}+Shift+o" = "move workspace to output right";
      "${config.modifier}+Alt+l" = "exec '${sway-lockscreen}/bin/sway-lockscreen &'";
      "${config.modifier}+Shift+e" = "mode $mode_system";
      "--locked XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer --increase 5";
      "--locked XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer --decrease 5";
      "--locked XF86AudioMute" = "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer --toggle-mute";
      "--locked XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player spotify play-pause";
      "--locked XF86AudioPause" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player spotify play-pause";
      "--locked XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player spotify next";
      "--locked XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl --player spotify previous";
      "--locked XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl -q set +10%";
      "--locked XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl -q set 10%-";
    };

    terminal = "${pkgs.alacritty}/bin/alacritty";
  };
}
