{...}: {
  # power
  powerManagement.enable = true;
  services.thermald.enable = true;
  # conflicts with auto-cpufreq
  services.tlp.enable = false;
  services.auto-cpufreq = {
    enable = false;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
