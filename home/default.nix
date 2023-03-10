{
  gui,
  username,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  homeDirectory = "/home/${username}";

  guiPkgs =
    if gui
    then
      (with pkgs; [
        (import ./import-nef.nix pkgs)
        android-udev-rules
        anki
        bitwarden
        borgbackup
        chromium
        czkawka
        darktable
        element-desktop
        evince
        gitAndTools.git-open
        gnomeExtensions.caffeine
        gnomeExtensions.dash-to-dock
        gnomeExtensions.vitals
        gnome-solanum
        inkscape
        libreoffice
        # https://github.com/NixOS/nixpkgs/issues/53079
        # mendeley
        musescore
        nextcloud-client
        obsidian
        signal-desktop
        skypeforlinux
        slack
        spotify
        texlab
        thunderbird
        todoist-electron
        vlc
        vorta
        wally-cli
        wl-clipboard
        xdg-utils
        xournalpp
        xwayland
        zoom-us
      ])
    else [];

  tuiPkgs = with pkgs;
    [
      (nerdfonts.override {fonts = ["Hack"];})
      fd
      file
      git-extras
      htop
      jq
      just
      krb5 # for cl access
      kubectx
      lf
      lm_sensors
      prettyping
      ripgrep
      sccache
      tree
      cachix
      ncdu
      papers
    ]
    ++ [(pkgs.callPackage ./weekly.nix {})];
in {
  imports =
    [
      ./xkb.nix
      (import ./latexmk.nix pkgs)
      (import ./neovim.nix pkgs)
      (import ./helix.nix)
    ]
    ++ (
      if gui
      then [
        ./dconf.nix
      ]
      else []
    );

  nixpkgs.config.allowUnfree = true;
  nix.package = lib.mkForce pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  home = {
    inherit homeDirectory username;
    sessionPath = ["${homeDirectory}/.cargo/bin"];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "vim";
    };

    stateVersion = "21.11";

    file = {
      ".cargo/config".text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        [net]
        git-fetch-with-cli = true
      '';

      ".config/papers/config.yaml".text = ''
        default_repo: ${homeDirectory}/Cloud/papers
        paper_defaults:
          tags:
            - '#new'
      '';
    };
  };

  fonts.fontconfig.enable = gui;

  home.packages = guiPkgs ++ tuiPkgs;

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-light";
      };
    };

    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    exa = {
      enable = true;
      enableAliases = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    ssh = import ./ssh.nix;

    git = import ./git.nix pkgs;

    firefox =
      if gui
      then (import ./firefox.nix pkgs)
      else {};

    taskwarrior = {
      enable = gui;
    };

    tmux = import ./tmux.nix;

    zsh = import ./zsh.nix pkgs;

    fish = import ./fish.nix pkgs;

    nushell = {
      enable = true;
    };

    nix-index.enable = true;

    vscode = {
      enable = gui;
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
  };

  services = {
    nextcloud-client = {
      enable = gui;
    };

    wlsunset = {
      enable = gui;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };
}
