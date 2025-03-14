{pkgs, ...}: {
  imports = [
    ./dconf.nix
    ./firefox.nix
    ../import-nef.nix
    ./mbsync.nix
    ./aerc.nix
    ./email.nix
    ./contacts.nix
    ./calendar.nix
    ./alacritty.nix
    ./papers.nix

    ./sway.nix
    ./lf.nix
    ./rbw.nix
  ];

  home.packages = with pkgs; [
    anki
    # bitwarden
    # bitwarden-cli
    calcurse
    calibre
    chromium
    czkawka
    darktable
    fractal
    flare-signal
    gitAndTools.git-open
    gramps
    libreoffice
    loupe
    musescore
    nextcloud-client
    obsidian
    organicmaps
    signal-desktop
    slack
    spotify
    tasksh
    taskwarrior-tui
    thunderbird
    vlc
    wally-cli
    waytext
    wdisplays
    wl-clipboard
    wl-mirror
    xdg-utils
    xwayland
  ];

  fonts.fontconfig.enable = true;

  programs = {
    taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      colorTheme = "light-256";
    };
  };

  services = {
    nextcloud-client = {
      enable = true;
    };

    udiskie.enable = true;

    wlsunset = {
      enable = true;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };
}
