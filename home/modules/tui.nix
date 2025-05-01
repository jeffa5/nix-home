{
  gui,
  nixSearch,
}: {pkgs, ...}: {
  imports = [
    ./bat.nix
    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./nushell.nix
    (import ./tmux.nix {server = !gui;})
    ./ssh.nix
    ./git.nix
    ./jujutsu.nix
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
  ];
  home.packages =
    [
      nixSearch
      pkgs.fd
      pkgs.file
      pkgs.git-extras
      pkgs.htop
      pkgs.iftop
      pkgs.jq
      pkgs.lf
      pkgs.lm_sensors
      pkgs.ncdu
      pkgs.nerd-fonts.hack
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.powertop
      pkgs.ripgrep
      pkgs.sccache
      pkgs.tree
      pkgs.unzip
      pkgs.wget
    ]
    ++ [
      (pkgs.callPackage ./weekly.nix {})
      (pkgs.callPackage ./daily.nix {})
    ];
}
