{pkgs, ...}: let
  vscodePkgs = pkgs.vscode-extensions;
in {
  programs.vscode = {
    enable = true;
    extensions = [
      vscodePkgs.vscodevim.vim
      vscodePkgs.matklad.rust-analyzer
      vscodePkgs.vadimcn.vscode-lldb
      vscodePkgs.ms-vscode-remote.remote-ssh
      vscodePkgs.jdinhlife.gruvbox
      vscodePkgs.ms-python.python
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
