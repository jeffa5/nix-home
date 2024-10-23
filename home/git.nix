{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    delta.enable = true;
    delta.options = {
      gruvbox-light = {
        syntax-theme = "gruvbox-light";
      };
      features = "gruvbox-light";
    };
    lfs.enable = true;
    userEmail = "dev@jeffas.net";
    userName = "Andrew Jeffery";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull = {
        ff = "only";
      };
      merge = {
        tool = "vimdiff";
      };
    };
  };
}
