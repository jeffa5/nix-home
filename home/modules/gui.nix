{pkgs, ...}: {
  imports = [
    ./dconf.nix
    ./firefox.nix
    ../import-nef.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    android-udev-rules
    anki
    bitwarden
    borgbackup
    chromium
    czkawka
    darktable
    fractal-next
    evince
    gitAndTools.git-open
    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals
    gnome-solanum
    gnome.gnome-dictionary
    gnome-network-displays
    inkscape
    libreoffice
    musescore
    nextcloud-client
    obsidian
    rnote
    signal-desktop
    skypeforlinux
    slack
    spotify
    thunderbird
    todoist-electron
    vlc
    vorta
    wally-cli
    wl-clipboard
    xdg-utils
    xournalpp
    xwayland
    zoom-us
  ];

  fonts.fontconfig.enable = true;

  programs = {
    taskwarrior = {
      enable = true;
    };
  };

  services = {
    nextcloud-client = {
      enable = true;
    };

    wlsunset = {
      enable = true;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };
}