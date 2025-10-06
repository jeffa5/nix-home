# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  nixpkgs,
  configs,
}: {pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules/btrfs.nix
    # (import ../modules/nix.nix {
    #   inherit nixpkgs;
    #   users = [];
    # })

    ../modules/openssh.nix
    ../modules/tailscale.nix

    # monitoring
    ../modules/node-exporter.nix
    ../modules/prometheus.nix
    ../modules/grafana.nix
    ../modules/loki.nix
    ../modules/promtail.nix

    ../modules/nginx.nix

    ../modules/nodeboard.nix
    (import ../modules/homeboard.nix {inherit configs;})

    (import ../modules/dnsmasq.nix {inherit configs;})

    # smart home
    ../modules/zigbee2mqtt.nix
    ../modules/mosquitto.nix
    ../modules/influxdb.nix

    ../modules/nextcloudcmd.nix
    ../modules/jellyfin.nix
    ../modules/git-server.nix
    ../modules/stagit.nix

    ../modules/nextcloud.nix
    # ../modules/immich.nix

    ../modules/postgres.nix
  ];

  services.nodeboard.enable = true;
  services.homeboard.enable = true;

  services.snapper = {
    configs."local" = {
      SUBVOLUME = "/local";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "cubenas";

  # Set your time zone.
  time.timeZone = "Europe/London";

  environment.systemPackages = [
    pkgs.vim
    pkgs.wget
    pkgs.htop
    pkgs.lm_sensors
    pkgs.dnsutils
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
