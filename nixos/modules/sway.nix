{pkgs, ...}: {
  programs.sway.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway --user-menu";
        user = "andrew";
      };
    };
  };
}
