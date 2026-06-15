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
    ./zed.nix
  ];

  home.packages = [
    pkgs.darktable
    pkgs.flare-signal
    pkgs.fractal
    pkgs.git-open
    pkgs.nh
    pkgs.spotify
    pkgs.vlc
    pkgs.wally-cli
    pkgs.waytext
    pkgs.wdisplays
    pkgs.wl-clipboard
    pkgs.wl-mirror
    pkgs.xdg-utils
    pkgs.sshfs
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
