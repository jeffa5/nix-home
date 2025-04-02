{pkgs, ...}: {
  xdg = {
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr];
    };
  };
  services = {
    gnome.gnome-online-accounts.enable = true;
    gnome.gnome-keyring.enable = true;
    xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
