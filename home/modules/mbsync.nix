{pkgs, ...}: {
  home.packages = [pkgs.isync];

  services.mbsync = {
    enable = true;
  };
}
