{pkgs, ...}: let
  fzf = pkgs.lib.getExe pkgs.fzf;
  rg = pkgs.lib.getExe pkgs.ripgrep;
  lf = pkgs.lib.getExe pkgs.lf;
in {
  programs.lf = {
    enable = true;
    previewer = {
      keybinding = "i";
      source = "${pkgs.ctpv}/bin/ctpv";
    };
    commands = {
      mkdir = "mkdir $f";
      fzf_jump_dir = ''
        ''${{
            res="$(find . -type d | ${fzf} --reverse --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                ${lf} -remote "send $id $cmd \"$res\""
            fi
        }}
      '';
      fzf_jump_file = ''
        ''${{
            res="$(find . -type f | ${fzf} --reverse --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                ${lf} -remote "send $id $cmd \"$res\""
            fi
        }}
      '';
      fzf_search = ''
        ''${{
            RG_PREFIX="${rg} --column --line-number --no-heading --color=always --smart-case "
            res="$(
                FZF_DEFAULT_COMMAND="$RG_PREFIX \'\'" \
                    ${fzf} --bind "change:reload:$RG_PREFIX {q} || true" \
                    --ansi --layout=reverse --header 'Search in files' \
                    | cut -d':' -f1 | sed 's/\\/\\\\/g;s/"/\\"/g'
            )"
            [ -n "$res" ] && ${lf} -remote "send $id select \"$res\""
        }}
      '';
    };
    keybindings = {
      # disable default
      f = null;
      fd = ":fzf_jump_dir";
      ff = ":fzf_jump_file";
      fc = ":fzf_search";
      gr = "cd /";
      gc = "cd ~/Cloud";
    };
    extraConfig = ''
      &${pkgs.ctpv}/bin/ctpv -s $id
      cmd on-quit %${pkgs.ctpv}/bin/ctpv -e $id
      set cleaner ${pkgs.ctpv}/bin/ctpvclear
    '';
  };
}
