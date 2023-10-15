{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "xps15";
  networking.interfaces.wlp2s0.useDHCP = true;

  services.printing = {
    enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };
}
