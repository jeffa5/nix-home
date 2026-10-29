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
    pkgs.claude-desktop
    pkgs.fractal
    pkgs.git-open
    pkgs.libreoffice
    pkgs.nautilus
    pkgs.nextcloud-native
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
    pkgs.thunar
    pkgs.xdg-utils
  ];

  fonts.fontconfig.enable = true;

  xdg.desktopEntries.netdata = {
    name = "Netdata";
    comment = "Local system monitoring dashboard";
    exec = "xdg-open http://localhost:19999/v3";
    icon = "utilities-system-monitor";
    terminal = false;
    categories = ["System" "Monitor"];
  };

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
