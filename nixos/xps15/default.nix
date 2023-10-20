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

  # power
  powerManagement.enable = true;
  services.thermald.enable = true;
  # conflicts with auto-cpufreq
  services.tlp.enable = false;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
}
