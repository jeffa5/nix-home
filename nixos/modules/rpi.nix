{pkgs, ...}: {
  imports = [
    ./openssh.nix

    ./nodeboard.nix
  ];

  services.nodeboard.enable = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

    loader = {
      grub.enable = false;

      generic-extlinux-compatible.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  hardware.enableRedistributableFirmware = true;
}
