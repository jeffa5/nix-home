{
  nixpkgs,
  users,
}: {pkgs, ...}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true

      min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    settings = {
      auto-optimise-store = true;

      trusted-users = ["root"] ++ users;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # make nix shell commands use same nixpkgs as system
    registry.nixpkgs.flake = nixpkgs;
  };
}
