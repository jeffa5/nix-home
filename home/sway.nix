{ pkgs, sway-scripts }:
let
  normal_bg = "#282828";
  normal_fg = "#ebdbb2";
  focus_bg = "#98971a";
  inactive_bg = "#282828";
  urgent_bg = "#cc241d";
in
rec {
  enable = true;
  extraConfig = ''
    set $workspace1 "1 "
    set $workspace2 "2 "
    set $workspace3 "3 "
    set $workspace4 "4  "
    set $workspace5 "5  "
    set $workspace6 "6  "
    set $workspace7 "7  "
    set $workspace8 "8 "
    set $workspace9 "9 "
    set $workspace10 "10 "

    set $mode_system System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (p) shutdown
    mode "$mode_system" {
        bindsym l exec --no-startup-id $locker, mode "default"
        bindsym e exit, mode "default"
        bindsym s exec --no-startup-id $locker && systemctl suspend, mode "default"
        bindsym h exec --no-startup-id $locker && systemctl hybrid-sleep, mode "default"
        bindsym r exec --no-startup-id systemctl reboot, mode "default"
        bindsym p exec --no-startup-id systemctl poweroff -i, mode "default"
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
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
      "*" = { xkb_layout = "iso-uk-colemak-dh"; };
      "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" = {
        middle_emulation = "enabled";
        tap = "enabled";
        natural_scroll = "enabled";
      };
    };

    output = {
      "*" = { bg = "#458588 solid_color"; };
      "eDP-1" = {
        position = "0 2160";
      };
      "HDMI-A-1" = {
        position = "0 1080";
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
      "${config.modifier}+space" = "exec ${sway-scripts}/bin/rofi";
      "${config.modifier}+Alt+f" = "exec --no-startup-id swaymsg 'workspace $workspace1; exec ${pkgs.firefox}/bin/firefox'";
      "${config.modifier}+Alt+s" = "exec --no-startup-id swaymsg 'workspace $workspace10; exec ${pkgs.spotify}/bin/spotify'";
      "${config.modifier}+Alt+m" = "exec --no-startup-id swaymsg 'workspace $workspace9; exec ${config.terminal}/bin/alacritty -e ${pkgs.aerc}/bin/aerc'";
      "${config.modifier}+Alt+n" = "exec --no-startup-id swaymsg 'workspace $workspace8; exec ${config.terminal} -e ${pkgs.newsboat}/bin/newsboat'";
      "${config.modifier}+c" = "exec ${sway-scripts}/bin/calc";
      "${config.modifier}+p" = "exec ${sway-scripts}/bin/screenshot";
      "${config.modifier}+t" = "exec ${sway-scripts}/bin/productivity-timer";
      "${config.modifier}+Shift+y" = "move workspace to output left";
      "${config.modifier}+Shift+u" = "move workspace to output down";
      "${config.modifier}+Shift+i" = "move workspace to output up";
      "${config.modifier}+Shift+o" = "move workspace to output right";
      "${config.modifier}+Alt+l" = "exec '${sway-scripts}/bin/lockscreen &'";
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
