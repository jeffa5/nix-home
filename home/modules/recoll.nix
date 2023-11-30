{...}: {
  services.recoll = {
    enable = true;
    settings = {
      cachedir = "~/.cache/recoll";
      "skippedNames+" = [
        ".cache"
        "node_modules" # node
        ".bundle" # ruby
        ".cargo" # rust
        "target" # rust
        ".rustup" # rust
        "result" # nix
        "build" # misc
        "3rdparty" # deps
        ".mypy_cache" # python
        ".venv" # python
        ".env" # python
        ".direnv" # python
        ".npm" # nodejs
        ".julia" # julia
        "_opam" # ocaml
        "_build" # ocaml
        "Steam" # steam
      ];
    };
  };
}
