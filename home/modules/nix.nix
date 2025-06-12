{username}: {
  pkgs,
  lib,
  ...
}: {
  nix.package = lib.mkForce pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };
  nix.extraOptions = ''
    !include /home/${username}/.config/nix/extra.conf
  '';
}
