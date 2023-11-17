{pkgs, ...}: {
  imports = [
    ./dconf.nix
    ./firefox.nix
    ../import-nef.nix
    ./mbsync.nix
    ./aerc.nix
    ./email.nix
    ./alacritty.nix

    ./sway.nix
    ./owork.nix
    ./lf.nix
  ];

  home.packages = with pkgs; [
    android-udev-rules
    anki
    bitwarden
    bitwarden-cli
    borgbackup
    calcurse
    chromium
    czkawka
    darktable
    fractal-next
    evince
    gitAndTools.git-open
    inkscape
    libreoffice
    musescore
    nextcloud-client
    obsidian
    rnote
    signal-desktop
    slack
    spotify
    thunderbird
    todoist-electron
    vlc
    vorta
    wally-cli
    waytext
    wdisplays
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
      colorTheme = "light-256";
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
