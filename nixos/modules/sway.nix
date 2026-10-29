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

  services.xserver.displayManager.lightdm.enable = false;

  services.greetd = {
    enable = false;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway --user-menu";
        user = "andrew";
      };
    };
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

  # trash://, mounts and network locations for nautilus/thunar
  services.gvfs.enable = true;

  # spacebar quick preview in nautilus
  services.gnome.sushi.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.andrew.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
