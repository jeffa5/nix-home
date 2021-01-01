{ colemakdh }:
{ config, pkgs, ... }:
let
  common-excludes = [
    ".cache"
    ".cargo" # rust
    "*/target" # rust
    "*/_build" # ocaml
    ".npm/_cacache" # node
    "*/node_modules" # node
    "*/venv" # python
    "*/.venv" # python
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
in
{
  imports = [ borgbackupMonitor ];

  time.timeZone = "Europe/London";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.andrew = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    zsh
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  console.packages = [ colemakdh ];
  console.keyMap = "iso-uk-colemak-dh";

  services = {
    pipewire = {
      enable = true;
    };

    fstrim.enable = true;

    borgbackup.jobs.home-andrew = rec {
      paths = "/home/andrew";
      exclude = map (x: paths + "/" + x) common-excludes;
      encryption = {
        mode = "keyfile-blake2";
        passphrase = "";
      };
      repo = "/backups/${config.networking.hostName}";
      compression = "auto,zstd,3";
      startAt = "hourly";
      doInit = false;
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
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  virtualisation.docker.enable = true;

  programs.sway.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
