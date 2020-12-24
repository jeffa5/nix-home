{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
    extraEntries = ''
      menuentry 'Arch Linux' {
        configfile (hd0,gpt1)/arch/grub/grub.cfg
      }
    '';
  };

  networking.hostName = "xps-15";
  networking.interfaces.wlp2s0.useDHCP = true;
}
