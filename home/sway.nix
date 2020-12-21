pkgs: {
  enable = true;
  extraConfig = ''
    # Logo key. Use Mod1 for Alt.
          set $mod Mod4
    # Home row direction keys, like vim
          set $left h
          set $down j
          set $up k
          set $right l
    # Your preferred terminal emulator
          set $term alacritty

    # Your preferred application launcher
          set $menu ~/.local/bin/sway/rofi

    # rename workspaces
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

    ### Output configuration
    #
    # Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
          output * bg ~/.wallpaper.png fill

    ### Input configuration
    #
    # Example configuration:
    #
    #   input "2:14:SynPS/2_Synaptics_TouchPad" {
    #       dwt enabled
    #       tap enabled
    #       natural_scroll enabled
    #       middle_emulation enabled
    #   }
    #
    # You can get the names of your inputs by running: swaymsg -t get_inputs
    # Read `man 5 sway-input` for more information about this section.
          input "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" {
          middle_emulation enabled
          tap enabled
          natural_scroll enabled
          }

    ### Key bindings
    #
    # Basics:
    #
        # start a terminal
          bindsym $mod+Return exec $term

        # kill focused window
          bindsym $mod+q kill

        # start your launcher
          bindsym $mod+space exec $menu

        # Drag floating windows by holding down $mod and left mouse button.
        # Resize them with right mouse button + $mod.
        # Despite the name, also works for non-floating windows.
        # Change normal to inverse to use left mouse button for resizing and right
        # mouse button for dragging.
          floating_modifier $mod normal

        # reload the configuration file
          bindsym $mod+Shift+r reload

    #
    # Moving around:
    #
        # Move your focus around
          bindsym $mod+$left focus left
          bindsym $mod+$down focus down
          bindsym $mod+$up focus up
          bindsym $mod+$right focus right
        # or use $mod+[up|down|left|right]
          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

        # _move_ the focused window with the same, but add Shift
          bindsym $mod+Shift+$left move left
          bindsym $mod+Shift+$down move down
          bindsym $mod+Shift+$up move up
          bindsym $mod+Shift+$right move right
        # ditto, with arrow keys
          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right
    #
    # Workspaces:
    #

        # switch to workspace
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
        # move focused container to workspace
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
        # Note: workspaces can have any name you want, not just numbers.
        # We just use 1-10 as the default.
    #
    # Layout stuff:
    #
        # You can "split" the current object of your focus with
        # $mod+b or $mod+v, for horizontal and vertical splits
        # respectively.
          bindsym $mod+b splith
          bindsym $mod+v splitv

        # Switch the current container between different layout styles
          bindsym $mod+s layout stacking
          bindsym $mod+w layout tabbed
          bindsym $mod+e layout toggle split

        # Make the current focus fullscreen
          bindsym $mod+f fullscreen

        # Toggle the current focus between tiling and floating mode
          bindsym $mod+Shift+space floating toggle

        # Swap focus between the tiling area and the floating area
        #bindsym $mod+space focus mode_toggle

        # move focus to the parent container
          bindsym $mod+a focus parent


    # start the udiskie program to automount drives
          exec --no-startup-id udiskie -N

    # start notification daemon
          exec --no-startup-id mako

    # start redshift
          exec --no-startup-id redshift
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
