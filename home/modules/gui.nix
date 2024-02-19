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
    ./recoll.nix
    ./pomo.nix
  ];

  home.packages = with pkgs; [
    amberol
    anki
    bitwarden
    bitwarden-cli
    calcurse
    chromium
    czkawka
    darktable
    fractal
    gitAndTools.git-open
    libreoffice
    musescore
    nextcloud-client
    obsidian
    rnote
    signal-desktop
    slack
    spotify
    tasksh
    taskwarrior-tui
    thunderbird
    vlc
    vorta
    wally-cli
    waytext
    wdisplays
    wl-clipboard
    xdg-utils
    xwayland
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
