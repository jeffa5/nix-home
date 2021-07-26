# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {
    "org/blueman/plugins/powermanager" = {
      auto-power-on = "@mb true";
    };

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      show-all-sources = false;
      sources = [ (mkTuple [ "xkb" "uk-colemakdh" ]) (mkTuple [ "xkb" "gb" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" ];
    };

    "org/gnome/desktop/interface" = {
      clock-show-date = true;
      clock-show-seconds = false;
      clock-show-weekday = true;
      cursor-size = 24;
      cursor-theme = "Adwaita";
      enable-animations = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Noto Sans,  10";
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      locate-pointer = false;
      show-battery-percentage = true;
      toolbar-style = "text";
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "thunderbird" "firefox" "zoom" "gnome-control-center" "org-gnome-tweaks" ];
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-control-center" = {
      application-id = "gnome-control-center.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/notifications/application/thunderbird" = {
      application-id = "thunderbird.desktop";
    };

    "org/gnome/desktop/notifications/application/zoom" = {
      application-id = "Zoom.desktop";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-microphone = false;
    };

    "org/gnome/desktop/screensaver" = {
      lock-delay = "uint32 0";
      lock-enabled = false;
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = "uint32 0";
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-smooth-graph = true;
      cpu-stacked-area-chart = false;
      current-tab = "processes";
      maximized = false;
      network-total-in-bits = false;
      show-dependencies = false;
      show-whose-processes = "user";
      solaris-mode = false;
      window-state = mkTuple [ 1438 621 ];
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      center-new-windows = false;
      dynamic-workspaces = true;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      search-filter-time-type = "last_modified";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Alt><Super>l" ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/shell" = {
      disabled-extensions = [ "apps-menu@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "appindicatorsupport@rgcjonas.gmail.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" "x11gestures@joseexposito.github.io" ];
      favorite-apps = [ "firefox.desktop" "Alacritty.desktop" "spotify.desktop" ];
      had-bluetooth-devices-setup = true;
      welcome-dialog-last-shown-version = "40.1";
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [ "Alacritty.desktop:2" "firefox.desktop:1" "spotify.desktop:5" "slack.desktop:3" "thunderbird.desktop:4" ];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

  };
}
