{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    settings = {
      user = {
        email = "dev@jeffas.net";
        name = "Andrew Jeffery";
      };
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
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      gruvbox-light = {
        syntax-theme = "gruvbox-light";
      };
      features = "gruvbox-light";
    };
  };
}
