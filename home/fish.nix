pkgs: {
  enable = true;

  shellAbbrs = {
    cat = "bat";
    ping = "prettyping --nolegend";
    g = "git";
    gc = "git commit -v";
    gst = "git status";
    gl = "git pull";
    gp = "git push";
    gpf = "git push --force-with-lease";
  };

  interactiveShellInit = ''
    set -g fish_greeting # disable welcome message
    fish_vi_key_bindings

    ${builtins.readFile ./gruvbox-fish.fish}

    base16-gruvbox-dark-medium
  '';
}
