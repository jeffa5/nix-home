{...}: {
  imports = [
    ./hardware-configuration.nix
    ../systemd-boot.nix
    (import ../modules/node-exporter.nix {openFirewall = false;})
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["kvm-intel" "coretemp" "nct6775"];

  networking.hostName = "carbide";
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp6s0.useDHCP = true;
}
