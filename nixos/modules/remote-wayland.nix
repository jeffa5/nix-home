{pkgs, ...}: {
  environment.systemPackages = [pkgs.waypipe];
  hardware.graphics.enable = true;
}
