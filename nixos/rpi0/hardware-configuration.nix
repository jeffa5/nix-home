{
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  fileSystems."/local" = {
    # usb 3.5 4TB drive
    device = "/dev/disk/by-uuid/7634a7da-f73b-4280-9691-933584483f20";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."${config.services.zigbee2mqtt.dataDir}" = {
    device = "/local/zigbee2mqtt";
    options = ["bind"];
  };

  fileSystems."${config.services.mosquitto.dataDir}" = {
    device = "/local/mosquitto";
    options = ["bind"];
  };

  fileSystems."/var/lib/influxdb2" = {
    device = "/local/influxdb2";
    options = ["bind"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.end0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
