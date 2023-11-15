{pkgs, ...}: let
  normal_bg = "#282828";
  normal_fg = "#ebdbb2";
  focus_bg = "#98971a";
  inactive_bg = "#282828";
  urgent_bg = "#cc241d";

  pamixer = "${pkgs.pamixer}/bin/pamixer";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in {
  imports = [
    ./swaylock.nix
    ./mako.nix
    ./zathura.nix
    ./imv.nix
    ./waybar.nix
    ./wofi.nix
  ];

  wayland.windowManager.sway = rec {
    enable = true;
    extraConfigEarly = ''
      set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
      exec rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | ${pkgs.wob}/bin/wob
    '';

    extraConfig = ''
      set $workspace1 1
      set $workspace2 2
      set $workspace3 3
      set $workspace4 4
      set $workspace5 5
      set $workspace6 6
      set $workspace7 7
      set $workspace8 8
      set $workspace9 9
      set $workspace10 10

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
        "*" = {bg = "#458588 solid_color";};
        "eDP-1" = {
          position = "320 1440";
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

      keybindings = let mod = config.modifier; in pkgs.lib.mkOptionDefault {
        "${mod}+q" = "kill";
        "${mod}+Shift+r" = "reload";
        "${mod}+1" = "workspace $workspace1";
        "${mod}+2" = "workspace $workspace2";
        "${mod}+3" = "workspace $workspace3";
        "${mod}+4" = "workspace $workspace4";
        "${mod}+5" = "workspace $workspace5";
        "${mod}+6" = "workspace $workspace6";
        "${mod}+7" = "workspace $workspace7";
        "${mod}+8" = "workspace $workspace8";
        "${mod}+9" = "workspace $workspace9";
        "${mod}+0" = "workspace $workspace10";
        "${mod}+minus" = "workspace back_and_forth";
        "${mod}+Shift+1" = "move container to workspace $workspace1";
        "${mod}+Shift+2" = "move container to workspace $workspace2";
        "${mod}+Shift+3" = "move container to workspace $workspace3";
        "${mod}+Shift+4" = "move container to workspace $workspace4";
        "${mod}+Shift+5" = "move container to workspace $workspace5";
        "${mod}+Shift+6" = "move container to workspace $workspace6";
        "${mod}+Shift+7" = "move container to workspace $workspace7";
        "${mod}+Shift+8" = "move container to workspace $workspace8";
        "${mod}+Shift+9" = "move container to workspace $workspace9";
        "${mod}+Shift+0" = "move container to workspace $workspace10";
        "${mod}+space" = "exec ${pkgs.sway-scripts.app-launcher}/bin/app-launcher";
        "${mod}+t" = "exec ${pkgs.sway-scripts.productivity-timer}/bin/productivity-timer";
        "${mod}+Alt+f" = "exec --no-startup-id swaymsg 'workspace $workspace1; exec ${pkgs.firefox}/bin/firefox'";
        "${mod}+Alt+m" = "exec --no-startup-id swaymsg 'workspace $workspace9; exec ${pkgs.thunderbird}/bin/thunderbird'";
        "${mod}+Alt+s" = "exec --no-startup-id swaymsg 'workspace $workspace10; exec ${pkgs.spotify}/bin/spotify'";
        "${mod}+p" = "exec ${pkgs.sway-scripts.screenshot}/bin/sway-screenshot";
        "${mod}+Shift+y" = "move workspace to output left";
        "${mod}+Shift+u" = "move workspace to output down";
        "${mod}+Shift+i" = "move workspace to output up";
        "${mod}+Shift+o" = "move workspace to output right";
        "${mod}+Alt+l" = "exec '${pkgs.sway-scripts.lockscreen}/bin/sway-lockscreen &'";
        "${mod}+Shift+e" = "mode $mode_system";
        "--locked XF86AudioRaiseVolume" = "exec --no-startup-id ${pamixer} --increase 5 && ${pamixer} --get-volume > $WOBSOCK";
        "--locked XF86AudioLowerVolume" = "exec --no-startup-id ${pamixer} --decrease 5 && ${pamixer} --get-volume > $WOBSOCK";
        "--locked XF86AudioMute" = "exec --no-startup-id ${pamixer} --toggle-mute && ( [ \"$(${pamixer} --get-mute)\" = \"true\" ] && echo 0 > $WOBSOCK ) || ${pamixer} --get-volume > $WOBSOCK";
        "--locked XF86AudioPlay" = "exec --no-startup-id ${playerctl} play-pause";
        "--locked XF86AudioPause" = "exec --no-startup-id ${playerctl} play-pause";
        "--locked XF86AudioNext" = "exec --no-startup-id ${playerctl} next";
        "--locked XF86AudioPrev" = "exec --no-startup-id ${playerctl} previous";
        "--locked XF86MonBrightnessUp" = "exec ${brightnessctl} set +10% | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";
        "--locked XF86MonBrightnessDown" = "exec ${brightnessctl} set 10%- | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";
      };

      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
  };
}
