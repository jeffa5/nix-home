{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      matklad.rust-analyzer
      vadimcn.vscode-lldb
      ms-vscode-remote.remote-ssh
      jdinhlife.gruvbox
      ms-python.python
    ];
    keybindings = [
      {
        key = "ctrl+shift+k";
        command = "workbench.action.showCommands";
      }
      {
        key = "ctrl+shift+p";
        command = "-workbench.action.showCommands";
      }
      {
        key = "ctrl+shift+k";
        command = "-editor.action.deleteLines";
        when = "textInputFocus && !editorReadonly";
      }
    ];
    userSettings = {
      "workbench.colorTheme" = "Gruvbox Light Hard";
      "rust-analyzer.checkOnSave.command" = "clippy";
      "files.trimTrailingWhitespace" = true;
    };
  };
}
