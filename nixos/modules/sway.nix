{
  pkgs,
  lib,
  ...
}: {
  programs.sway = {
    enable = true;
    # null so that we use the home-manager sway module
    package = null;
    extraPackages = [];
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway --user-menu";
        user = "andrew";
      };
    };
  };

  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  # https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = let
          green = "00ff0055";
          makoctl = lib.getExe' pkgs.mako "makoctl";
        in {
          exec_before = "${makoctl} mode -a dnd";
          exec_after = "${makoctl} mode -r dnd";
          chooser_cmd = "${lib.getExe pkgs.slurp} -f %o -or -s ${green}";
          chooser_type = "simple";
        };
      };
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = [pkgs.libsecret];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.andrew.enableGnomeKeyring = true;
}
