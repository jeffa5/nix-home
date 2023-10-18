{pkgs, ...}: {
  programs.sway = {
    enable = true;
    # null so that we use the home-manager sway module
    package = null;
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      # pkgs.xdg-desktop-portal-gtk
    ];
  };
}
