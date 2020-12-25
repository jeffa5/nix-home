pkgs: {
  enable = true;
  extraConfig = ''
    set $mod Mod4

    set $left h
    set $down j
    set $up k
    set $right l

    set $term alacritty

    set $menu ~/.local/bin/sway/rofi

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

    output * bg #458588 fill

    input "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" {
      middle_emulation enabled
      tap enabled
      natural_scroll enabled
    }

    bindsym $mod+Return exec $term

    bindsym $mod+q kill

    bindsym $mod+space exec $menu

    floating_modifier $mod normal

    bindsym $mod+Shift+r reload

    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    bindsym $mod+1 workspace $workspace1
    bindsym $mod+2 workspace $workspace2
    bindsym $mod+3 workspace $workspace3
    bindsym $mod+4 workspace $workspace4
    bindsym $mod+5 workspace $workspace5
    bindsym $mod+6 workspace $workspace6
    bindsym $mod+7 workspace $workspace7
    bindsym $mod+8 workspace $workspace8
    bindsym $mod+9 workspace $workspace9
    bindsym $mod+0 workspace $workspace10

    bindsym $mod+Shift+1 move container to workspace $workspace1
    bindsym $mod+Shift+2 move container to workspace $workspace2
    bindsym $mod+Shift+3 move container to workspace $workspace3
    bindsym $mod+Shift+4 move container to workspace $workspace4
    bindsym $mod+Shift+5 move container to workspace $workspace5
    bindsym $mod+Shift+6 move container to workspace $workspace6
    bindsym $mod+Shift+7 move container to workspace $workspace7
    bindsym $mod+Shift+8 move container to workspace $workspace8
    bindsym $mod+Shift+9 move container to workspace $workspace9
    bindsym $mod+Shift+0 move container to workspace $workspace10

    bindsym $mod+b splith
    bindsym $mod+v splitv

    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    bindsym $mod+f fullscreen

    bindsym $mod+Shift+space floating toggle

    bindsym $mod+a focus parent

    include ~/.config/sway/config.d/*
  '';
  config = {
    modifier = "Mod4";
    keybindings = { };
    bars = [
      {
        command = "\${pkgs.waybar}/bin/waybar";
      }
    ];
  };
}
