{pkgs, ...}: {
  programs.zsh = {
    enable = false;
    plugins = [
      {
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
      plugins = ["git" "gitfast" "docker"];
    };

    dotDir = ".config/zsh";

    shellAliases = {
      cat = "bat";
      gdm = "git diff master";
      wiki = "vim ~/wiki/index.md";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      KEYTIMEOUT = 1;
    };

    initExtra = ''
      bindkey -v
      bindkey '^?' backward-delete-char
      bindkey '^h' backward-delete-char
      bindkey '^w' backward-kill-word
      bindkey '^r' fzf-history-widget

      autoload -U colors && colors

      MAGENTA="%{$fg_bold[magenta]%}"
      CYAN="%{$fg_bold[cyan]%}"
      BLUE="%{$fg_bold[blue]%}"
      GREEN="%{$fg_bold[green]%}"
      YELLOW="%{$fg_bold[yellow]%}"
      RED="%{$fg_bold[red]%}"
      WHITE="%{$fg_bold[white]%}"
      RESET="%{$reset_color%}"

      autoload -Uz vcs_info
      precmd_vcs_info() { vcs_info }
      precmd_functions+=( precmd_vcs_info )
      zstyle ':vcs_info:git:*' formats "''${MAGENTA}:''${YELLOW}%b"

      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line


      zstyle ':completion:*:*:make:*' tag-order 'targets'

      autoload -U +X bashcompinit && bashcompinit
      autoload -Uz compinit && compinit -i
    '';
  };
}
