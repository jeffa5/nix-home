# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9d8c4113-dd4f-44d3-876a-26bea41ed6e3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0E1B-9AA9";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/53340e82-11f4-406e-9b51-f1d092736fa7";
    fsType = "ext4";
  };

  fileSystems."/backups" = {
    device = "/dev/disk/by-uuid/7634a7da-f73b-4280-9691-933584483f20";
    fsType = "ext4";
    options = ["nofail"];
  };

  swapDevices = [{device = "/dev/disk/by-uuid/33248a0d-a191-45f5-b23b-eaad350022e6";}];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.cpu.intel.updateMicrocode = true;
}
