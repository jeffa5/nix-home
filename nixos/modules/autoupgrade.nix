{...}: {
  system.autoUpgrade = {
    enable = true;
    flake = "github:jeffa5/nix-home";
    dates = "04:40";
    allowReboot = false;
    flags = ["--verbose"];
  };
}
