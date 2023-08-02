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
  gnome = gui;
  plasma = false;
  locale = "en_GB.UTF-8";
in {
  imports = [];

  time.timeZone = "Europe/London";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = overlays;

  networking.networkmanager.enable = true;
  networking.networkmanager.enableStrongSwan = true;

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
    strongswan
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true

      min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    settings = {
      auto-optimise-store = true;

      trusted-users = ["root"] ++ users;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # make nix shell commands use same nixpkgs as system
    registry.nixpkgs.flake = nixpkgs;
  };

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

    # Check status at
    # https://myip.uis.cam.ac.uk/
    strongswan = {
      enable = true;
      # Passwords set up as per https://help.uis.cam.ac.uk/service/network-services/remote-access/uis-vpn/ubuntu1604#password-file
      secrets = ["/var/lib/ipsec.secrets"];
      # charondebug = "all";

      connections."%default" = {
        keyexchange = "ikev2";
        ikelifetime = "60m";
        keylife = "20m";
        rekeymargin = "3m";
        keyingtries = "1";
      };

      connections.CAM = {
        left = "%any";
        leftid = "apj39+xps15vpn@cam.ac.uk";
        leftauth = "eap";
        leftsourceip = "%config";
        leftfirewall = "yes";
        right = "vpn.uis.cam.ac.uk";
        rightid = "\"CN=vpn.uis.cam.ac.uk\"";
        # from https://help.uis.cam.ac.uk/service/network-services/remote-access/uis-vpn/ubuntu1604
        rightcert = toString ./cambridge-vpn-2022.crt;
        rightsubnet = "0.0.0.0/0";
        auto = "add";
      };

      # Setup instructions: https://www.cst.cam.ac.uk/local/sys/vpn2/linux
      # Password from https://vpnpassword.cl.cam.ac.uk/
      connections.CL = {
        reauth = "no";
        left = "%any";
        leftid = "apj39-xps15";
        leftauth = "eap";
        leftsourceip = "%config4,%config6";
        leftfirewall = "yes";
        right = "vpn2.cl.cam.ac.uk";
        rightid = "%any";
        rightsendcert = "never";
        rightsubnet = "128.232.0.0/16,129.169.0.0/16,131.111.0.0/16,192.18.195.0/24,193.60.80.0/20,193.63.252.0/23,172.16.0.0/13,172.24.0.0/14,172.28.0.0/15,172.30.0.0/16,10.128.0.0/9,10.64.0.0/10,2001:630:210::/44,2a05:b400::/32";
        auto = "add";
      };
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

    gnome.gnome-online-accounts.enable = gnome;
    gnome.gnome-keyring.enable = gnome;

    tailscale.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs;
        [
          xdg-desktop-portal-wlr
        ]
        ++ (
          if plasma
          then [xdg-desktop-portal-gtk]
          else []
        );
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

    displayManager.sddm.enable = plasma;
    desktopManager.plasma5.enable = plasma;

    displayManager.gdm.enable = gnome;
    desktopManager.gnome.enable = gnome;
  };

  programs = {
    steam.enable = true;

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
