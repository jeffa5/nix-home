{pkgs, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Andrew Jeffery";
        email = "dev@jeffas.net";
      };
    };
  };
}
