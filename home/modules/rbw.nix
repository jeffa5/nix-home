{pkgs, ...}: {
  home.packages = [pkgs.rbw];

  xdg.configFile."rbw/config.json".text = builtins.toJSON {
    email = "andrewjeffery97@gmail.com";
    pinentry = pkgs.lib.getExe pkgs.pinentry;
  };
}
