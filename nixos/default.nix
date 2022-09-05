{ colemakdh, nixpkgs }:
{ config, pkgs, ... }:
let
  common-excludes = [
    ".cache"
    ".cargo" # rust
    "*/target" # rust
    "*/_opam" # ocaml
    "*/_build" # ocaml
    ".npm/_cacache" # node
    "*/node_modules" # node
    "*/venv" # python
    "*/.venv" # python
    "go/pkg/mod/cache" # golang
    ".config/Slack/Cache" # slack
    ".config/Microsoft/Microsoft Teams/Cache" # ms teams
    ".kube" # kubernetes
  ];

  borgbackupMonitor = { config, pkgs, lib, ... }: with lib; {
    key = "borgbackupMonitor";
    _file = "borgbackupMonitor";
    config.systemd.services = {
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "andrew";
        environment.SERVICE = "%i";
        script = ''
          export $(cat /proc/$(${pkgs.procps}/bin/pgrep sway --oldest -u "$USER")/environ | grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run the below for details\njournalctl -u $SERVICE"
        '';
      };
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@%i.service";
      }
    );
  };

  gnome = true;
  plasma = false;
in
{
  imports = [ borgbackupMonitor ];

  time.timeZone = "Europe/London";
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.enableStrongSwan = true;
  networking.useDHCP = false;

  hardware = {
    bluetooth.enable = true;
    keyboard.zsa.enable = true;
    pulseaudio.enable = false;
  };

  users = {
    extraGroups.vboxusers.members = [ "andrew" ];

    users.andrew = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "plugdev" "adbusers" ];
      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    zsh
    fish
  ];

  nix = {
    package = pkgs.nixFlakes;

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true

      min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    settings = {
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # make nix shell commands use same nixpkgs as system
    registry.nixpkgs.flake = nixpkgs;
  };

  console.packages = [ colemakdh ];
  console.keyMap = "iso-uk-colemak-dh";
  console.earlySetup = true;

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

    borgbackup.jobs.home-andrew = rec {
      paths = "/home/andrew";
      exclude = map (x: paths + "/" + x) common-excludes;
      encryption = {
        mode = "none";
      };
      repo = "/backups/backups/${config.networking.hostName}/borg";
      doInit = false;
      compression = "auto,zstd,3";
      startAt = "hourly";
      extraCreateArgs = "--verbose --stats --list --filter=AME --checkpoint-interval 600";
      extraPruneArgs = "--verbose --stats --list --save-space";
      prune = {
        keep = {
          hourly = 24;
          daily = 7;
          weekly = 4;
          monthly = -1;
        };
      };
      removableDevice = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint hplip ];
    };

    gnome.gnome-online-accounts.enable = gnome;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ] ++ (if plasma then [ xdg-desktop-portal-gtk ] else [ ]);
      gtkUsePortal = true;
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  services.xserver = {
    layout = "uk-cdh,gb";

    extraLayouts.uk-cdh = {
      description = "UK Colemak";
      languages = [ "eng" ];
      symbolsFile = ./../packages/colemakdh/iso-uk-colemak-dh;
    };

    enable = true;

    displayManager.sddm.enable = plasma;
    desktopManager.plasma5.enable = plasma;

    displayManager.gdm.enable = gnome;
    desktopManager.gnome.enable = gnome;
  };

  programs = {
    sway.enable = false;

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
  boot.tmpOnTmpfs = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
