pkgs: {
  enable = true;
  plugins = [
    {
      # will source zsh-autosuggestions.plugin.zsh
      name = "zsh-autosuggestions";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-autosuggestions";
        rev = "v0.4.0";
        sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
      };
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-syntax-highlighting";
        rev = "0.7.1";
        sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
      };
    }
    {
      name = "alias-tips";
      src = pkgs.fetchFromGitHub {
        owner = "djui";
        repo = "alias-tips";
        rev = "master";
        sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
      };
    }
  ];
  oh-my-zsh = {
    enable = true;
    plugins = [ "git" "gitfast" ];
  };

  initExtra = ''
      source ~/.zsh/vi
      source ~/.zsh/aliases
      source ~/.zsh/prompt
      [ -f ~/.zsh/local_aliases ] && source ~/.zsh/local_aliases

      export EDITOR=nvim
      export VISUAL=nvim

      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line

      export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

      zstyle ':completion:*:*:make:*' tag-order 'targets'

    # OPAM configuration
      . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      fpath+=${ZDOTDIR:-~}/.zsh/functions

      autoload -U +X bashcompinit && bashcompinit
      autoload -Uz compinit && compinit -i

      export TERM=xterm-256color
  '';
}
