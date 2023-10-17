{
  colemakdh,
  nixpkgs,
  overlays,
  users,
  gui,
}: {
  config,
  pkgs,
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
    ]
    ++ (
      if gui
      then [./modules/gnome.nix]
      else []
    )
    ++ (
      if plasma
      then [./modules/plasma.nix]
      else []
    );

  time.timeZone = "Europe/London";
  nixpkgs.overlays = overlays;

  networking.networkmanager.enable = true;

  hardware = {
    bluetooth.enable = true;
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

    printing = {
      enable = true;
      drivers = with pkgs; [gutenprint hplip];
    };
  };

  virtualisation.docker.enable = true;

  services.xserver = {
    layout = "uk-cdh,gb";

    extraLayouts.uk-cdh = {
      description = "UK Colemak";
      languages = ["eng"];
      symbolsFile = ./../packages/colemakdh/iso-uk-colemak-dh;
    };

    enable = true;
  };

  programs = {
    sway.enable = false;

    steam.enable = true;

    adb.enable = true;

    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
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
  system.stateVersion = "20.09"; # Did you read the comment?
}
