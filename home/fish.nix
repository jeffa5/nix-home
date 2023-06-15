_pkgs: {
  enable = true;

  shellAbbrs = {
    cat = "bat";
    ping = "prettyping --nolegend";
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

  shellAliases = {
    wiki = "cd ~/Cloud/Obsidian/Home && nvim && popd";
  };

  interactiveShellInit = ''
    set -g fish_greeting # disable welcome message
    fish_vi_key_bindings

    ${builtins.readFile ./gruvbox-fish.fish}

    base16-gruvbox-light-medium
  '';
}
