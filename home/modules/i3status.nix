{
  pkgs,
  lib,
  ...
}: {
  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        blocks = [
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 60;
            warning = 20.0;
            alert = 10.0;
          }
          {
            block = "memory";
            format_mem = " $icon $mem_used_percents ";
            format_swap = " $icon $swap_used_percents ";
          }
          {
            block = "cpu";
            interval = 1;
          }
          {
            block = "load";
            interval = 1;
            format = " $icon $1m ";
          }
          {block = "sound";}
          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          }
        ];
        settings = {
          theme = {
            theme = "gruvbox-light";
            overrides = {
              idle_bg = "#123456";
              idle_fg = "#abcdef";
            };
          };
        };
        icons = "awesome5";
        theme = "gruvbox-light";
      };
    };
  };
  wayland.windowManager.sway.config.bars = let
    bar = pkgs.writeShellScriptBin "i3status-rs" ''
      ${lib.getExe pkgs.i3status-rust} ~/.config/i3status-rust/config-bottom.toml
    '';
  in [
    {
      command = lib.getExe' bar "i3status-rs";
      position = "top";
    }
  ];
}
