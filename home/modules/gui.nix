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

  home.packages = [
    pkgs.anki
    # bitwarden
    # bitwarden-cli
    pkgs.calcurse
    pkgs.calibre
    pkgs.chromium
    pkgs.czkawka
    pkgs.darktable
    pkgs.fractal
    pkgs.flare-signal
    pkgs.gitAndTools.git-open
    pkgs.gramps
    pkgs.libreoffice
    pkgs.loupe
    pkgs.musescore
    pkgs.nextcloud-client
    pkgs.obsidian
    pkgs.organicmaps
    pkgs.signal-desktop
    pkgs.slack
    pkgs.spotify
    pkgs.tasksh
    pkgs.taskwarrior-tui
    pkgs.thunderbird
    pkgs.vlc
    pkgs.wally-cli
    pkgs.waytext
    pkgs.wdisplays
    pkgs.wl-clipboard
    pkgs.wl-mirror
    pkgs.xdg-utils
    pkgs.xwayland
    pkgs.timewarrior
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
