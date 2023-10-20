{...}: {
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
      governor = "powersave";
      turbo = "auto";
    };
  };
}
