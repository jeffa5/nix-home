{pkgs, ...}: {
  imports = [
    ./openssh.nix
    # ./autoupgrade.nix

    # ./nodeboard.nix
  ];

  # services.nodeboard.enable = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

    loader = {
      grub.enable = false;

      generic-extlinux-compatible.enable = true;
    };
  };

  environment.systemPackages = [
    pkgs.libraspberrypi
    pkgs.raspberrypi-eeprom
  ];

  hardware.enableRedistributableFirmware = true;
}
