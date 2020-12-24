pkgs: {
  enable = true;
  package = pkgs.gitAndTools.gitFull;
  delta.enable = true;
  userEmail = "dev@jeffas.io";
  userName = "Andrew Jeffery";
  extraConfig = {
    pull = {
      ff = "only";
    };
  };
}
