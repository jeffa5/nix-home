{...}: {
  programs.fish = {
    enable = true;

    functions = {
      bwu = "set -xU BW_SESSION (bw unlock --raw $argv[1])";
    };

    shellAliases = {
      wiki = "pushd ~/Cloud/Obsidian/Home && nvim && popd";
    };

    interactiveShellInit = ''
      set -g fish_greeting # disable welcome message
      fish_vi_key_bindings

      ${builtins.readFile ./gruvbox-fish.fish}

      base16-gruvbox-light-medium
    '';
  };
}
