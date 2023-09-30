{nixpkgs}: {pkgs, ...}: {
  imports = [
    (import ../modules/nix.nix {
      inherit nixpkgs;
      users = [];
    })
    ../modules/openssh.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "rpi1";

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "23.05";
}
