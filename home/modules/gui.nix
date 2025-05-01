{pkgs, ...}: {
  imports = [
    ./xdg.nix
    ./dconf.nix
    ./firefox.nix
    ../import-nef.nix
    ./mbsync.nix
    ./aerc.nix
    ./email.nix
    ./contacts.nix
    ./calendar.nix
    ./foot.nix
    ./papers.nix

    ./sway.nix
    ./lf.nix
    ./rbw.nix
    ./newsboat.nix
  ];

  home.packages = [
    # bitwarden
    # bitwarden-cli
    pkgs.anki
    pkgs.calcurse
    pkgs.calibre
    pkgs.chromium
    pkgs.czkawka
    pkgs.darktable
    pkgs.flare-signal
    pkgs.fractal
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
    pkgs.timewarrior
    pkgs.vlc
    pkgs.wally-cli
    pkgs.waytext
    pkgs.wdisplays
    pkgs.wl-clipboard
    pkgs.wl-mirror
    pkgs.xdg-utils
    pkgs.xwayland
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
      latitude = 51.5;
      longitude = 0.1;
    };
  };
}
