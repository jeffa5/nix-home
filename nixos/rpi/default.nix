{pkgs, ...}: {
  imports = [
    # ./hardware-configuration.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "23.05";
}
