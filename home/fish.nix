pkgs: {
  enable = true;

  shellAbbrs = {
    cat = "bat";
    ping = "prettyping --nolegend";
  };

  interactiveShellInit = ''
    set -g fish_greeting # disable welcome message
    fish_vi_key_bindings

    ${builtins.readFile ./gruvbox-fish.fish}

    base16-gruvbox-dark-medium
  '';
}
