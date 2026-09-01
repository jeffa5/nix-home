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
    # ./papers.nix

    ./sway.nix
    ./lf.nix
    ./rbw.nix
    ./newsboat.nix
    ./thunderbird.nix
    ./zed.nix
  ];

  home.packages = [
    pkgs.darktable
    pkgs.fractal
    pkgs.git-open
    pkgs.libreoffice
    pkgs.nh
    pkgs.signal-desktop
    pkgs.spotify
    pkgs.sshfs
    pkgs.vlc
    pkgs.wally-cli
    pkgs.waytext
    pkgs.wdisplays
    pkgs.wl-clipboard
    pkgs.wl-mirror
    pkgs.xdg-utils
  ];

  fonts.fontconfig.enable = true;

  services = {
    syncthing = {
      enable = true;
    };

    wlsunset = {
      enable = true;
      latitude = 51.5;
      longitude = 0.1;
    };
  };
}
