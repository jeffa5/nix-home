{pkgs, ...}: {
  home.packages = [
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.dash-to-dock
    pkgs.gnomeExtensions.vitals
    pkgs.gnome-solanum
    pkgs.gnome.gnome-dictionary
    pkgs.gnome-network-displays
  ];
}
