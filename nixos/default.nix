{
  colemakdh,
  nixpkgs,
  overlays,
  users,
  gui,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  plasma = false;
  locale = "en_GB.UTF-8";
in {
  imports =
    [
      (import ./modules/nix.nix {inherit nixpkgs users;})
      ./modules/vpn.nix
      ./modules/tailscale.nix
      ./modules/restic.nix
      ./modules/autoupgrade.nix

      ./modules/nodeboard.nix
    ]
    ++ (
      if gui
      then [
        # ./modules/gnome.nix
        ./modules/sway.nix
      ]
      else []
    )
    ++ (
      if plasma
      then [./modules/plasma.nix]
      else []
    );

  nixpkgs.overlays = overlays;
  nixpkgs.config.permittedInsecurePackages =
    pkgs.lib.optional (pkgs.obsidian.version == "1.4.16") "electron-25.9.0";

  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  hardware = {
    bluetooth.enable = true;
    # experimental to get the battery status feature
    bluetooth.package = pkgs.bluez5-experimental;
    bluetooth.settings.General.Experimental = true;

    keyboard.zsa.enable = true;
    pulseaudio.enable = false;
  };

  users = {
    extraGroups.vboxusers.members = users;

    users.andrew = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker" "networkmanager" "plugdev" "adbusers"];
      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    zsh
    fish
  ];

  console.packages = [colemakdh];
  console.keyMap = "iso-uk-colemak-dh";
  console.earlySetup = true;

  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_GB";
    LC_ALL = locale;
  };

  security.rtkit.enable = true;
  services = {
    ananicy = {
      enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    blueman = {
      enable = false;
    };

    fstrim.enable = true;

    udisks2.enable = gui;

    fwupd.enable = true;

    automatic-timezoned.enable = true;
    # mozilla's service is deprecated
    geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

    tzupdate.enable = true;
  };

  # udev 250 doesn't reliably reinitialize devices after restart
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  virtualisation.docker.enable = true;

  services.xserver = {
    xkb.layout = "uk-cdh,gb";

    xkb.extraLayouts.uk-cdh = {
      description = "UK Colemak";
      languages = ["eng"];
      symbolsFile = ./../packages/colemakdh/iso-uk-colemak-dh;
    };

    enable = true;

    excludePackages = [pkgs.xterm];
  };

  programs = {
    adb.enable = true;

    nm-applet.enable = true;

    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };

    fuse.userAllowOther = true;
  };

  # boot.kernel.sysctl."fs.inotify.max_user_watches" = pkgs.lib.mkDefault 524288;
  boot.tmp.useTmpfs = true;

  # register QEMU as a binfmt wrapper for the aarch64 architecture
  # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  system.userActivationScripts.diff = ''
    if [[ -e /run/current-system ]]; then
      ${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" || true
    fi
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.mkDefault "20.09"; # Did you read the comment?
}
