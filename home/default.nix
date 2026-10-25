{
  gui,
  username,
  rical,
}: {...}: {
  imports =
    [
      rical.homeManagerModules.default
      (import ./modules/home.nix {inherit username;})
      (import ./modules/tui.nix {inherit gui;})
      ./xkb.nix
      ./neovim.nix
      # ./helix.nix
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
