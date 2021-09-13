{ colemakdh, waytext, owork }:
{ config, pkgs, ... }:
let
  waytext-bin = "${waytext.packages.x86_64-linux.waytext}/bin/waytext";
  productivity-timer-notify = pkgs.writeScriptBin "productivity-timer-notify" ''
    #!${pkgs.stdenv.shell}

    pgrep waytext && pkill waytext

    case "$1" in
    "Idle")
        text="Idle"
        ;;
    "Work")
        text="Start work"
        ;;
    "Short")
        text="Take a short break"
        ;;
    "Long")
        text="Take a long break"
        ;;
    esac

    ${waytext-bin} -t "$text"
  '';
  owork-args = [
    "--work-duration 30"
    "--short-break 5"
    "--long-break 15"
    "--work-sessions 4"
    "--notify-script ${productivity-timer-notify}/bin/productivity-timer-notify"
  ];
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
in
{
  imports = [ borgbackupMonitor ];

  time.timeZone = "Europe/London";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  hardware = {
    bluetooth.enable = true;
  };

  users = {
    extraGroups.vboxusers.members = [ "andrew" ];

    users.andrew = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" ];
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

    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  console.packages = [ colemakdh ];
  console.keyMap = "iso-uk-colemak-dh";
  console.earlySetup = true;

  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    blueman = {
      enable = true;
    };

    fstrim.enable = true;

    borgbackup.jobs.home-andrew = rec {
      paths = "/home/andrew";
      exclude = map (x: paths + "/" + x) common-excludes;
      encryption = {
        mode = "none";
      };
      repo = "/backups/${config.networking.hostName}";
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

  systemd.user.services.owork = {
    description = "owork productivity timer";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${owork.packages.x86_64-linux.owork}/bin/owork ${builtins.concatStringsSep " " owork-args}";
      Restart = "on-failure";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  services.xserver = {
    layout = "uk-colemakdh";

    extraLayouts.uk-colemakdh = {
      description = "UK Colemak";
      languages = [ "eng" ];
      symbolsFile = ./../packages/colemakdh/iso-uk-colemak-dh;
    };
  };

  programs = {
    sway.enable = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
