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
      ./modules/tailscale.nix
      ./modules/restic.nix
      ./modules/autoupgrade.nix
      ./modules/slim.nix

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

  networking.networkmanager.enable = false;


  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  hardware = {
    bluetooth.enable = true;
    # experimental to get the battery status feature
    bluetooth.package = pkgs.bluez5-experimental;
    bluetooth.settings.General.Experimental = true;

    keyboard.zsa.enable = true;
  };

  users = {
    extraGroups.vboxusers.members = users;

    users.andrew = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker" "networkmanager" "plugdev" "adbusers" "libvirtd"];
      shell = pkgs.fish;
    };
  };

  environment.systemPackages = [
    pkgs.fish
    pkgs.impala
    pkgs.bluetui
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

    dbus.implementation = "broker";

    irqbalance.enable = true;
  };

  # udev 250 doesn't reliably reinitialize devices after restart
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = false;

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

  zramSwap.enable = true; # Creates a zram block device and uses it as a swap device

  # boot.kernel.sysctl."fs.inotify.max_user_watches" = pkgs.lib.mkDefault 524288;
  boot.tmp.useTmpfs = true;
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  boot.initrd.systemd.enable = true;

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
