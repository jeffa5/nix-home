{pkgs, ...}: {
  # power
  powerManagement.enable = true;
  services.thermald.enable = true;

  # local battery/system monitoring, web UI on localhost:19999
  services.netdata.enable = true;
  # nixpkgs builds netdata without the local dashboard UI by default
  # (withCloudUi = false), which makes localhost:19999 404 on every
  # path ("File does not exist, or is not accessible")
  services.netdata.package = pkgs.netdata.override {withCloudUi = true;};
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
