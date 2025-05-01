{
  gui,
  username,
  wordnet-ls,
  maills,
  icalls,
  nixSearch,
}: {...}: {
  imports =
    [
      (import ./modules/home.nix {inherit username;})
      (import ./modules/tui.nix {inherit gui nixSearch;})
      ./xkb.nix
      ./latexmk.nix
      (import ./neovim.nix {inherit wordnet-ls maills icalls;})
      ./helix.nix
      ./modules/cargo.nix
      (import ./modules/nix.nix {inherit username;})
    ]
    ++ (
      if gui
      then [
        ./modules/gui.nix
      ]
      else []
    );
}
