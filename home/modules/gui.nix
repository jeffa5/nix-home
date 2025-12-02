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
    pkgs.anki
    pkgs.calcurse
    pkgs.chromium
    pkgs.darktable
    pkgs.flare-signal
    pkgs.fractal
    pkgs.git-open
    pkgs.gramps
    pkgs.libreoffice
    pkgs.loupe
    pkgs.nextcloud-client
    pkgs.signal-desktop
    pkgs.spotify
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
