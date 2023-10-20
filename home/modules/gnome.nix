{pkgs, ...}: {
  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals
    gnome-solanum
    gnome.gnome-dictionary
    gnome-network-displays
  ];
}
