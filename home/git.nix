pkgs: {
  enable = true;
  package = pkgs.gitAndTools.gitFull;
  delta.enable = true;
  userEmail = "dev@jeffas.io";
  userName = "Andrew Jeffery";
  extraConfig = {
    init = {
      defaultBranch = "main";
    };
    pull = {
      ff = "only";
    };
  };
}
