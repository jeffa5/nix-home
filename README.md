# My nix/nixos config

Install nix: https://nixos.org/download.html#download-nix

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Set up a home profile:

```sh
nix run --extra-experimental-features "nix-command flakes" nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake github:jeffa5/nix-home#apj39-tui
```

After installing a system, use `make nvd` to show the diff in an upgrade.
