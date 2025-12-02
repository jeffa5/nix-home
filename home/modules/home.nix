{username}: {...}: let
  homeDirectory = "/home/${username}";
in {
  home = {
    inherit homeDirectory username;
    sessionPath = ["${homeDirectory}/.cargo/bin"];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "nvim";
    };

    shellAliases = {
      cat = "bat";
      g = "git";
      ga = "git add";
      gc = "git commit -v";
      gd = "git diff";
      gdm = "git diff main";
      gst = "git status";
      gl = "git pull";
      glum = "git pull upstream main";
      gp = "git push";
      gpu = "git push --set-upstream origin HEAD";
      gpf = "git push --force-with-lease";
      gcm = "git checkout main";
      grb = "git rebase";
      grbm = "git rebase main";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      gsh = "git show";
      glog = "git log --oneline --graph";
      gco = "git checkout";
      gcb = "git checkout -b";
      gstp = "git stash pop";
    };

    stateVersion = "21.11";
  };
  programs.home-manager.enable = true;
}
