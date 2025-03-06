{...}: {
  nix.gc = {
    automatic = true;
    frequency = "daily";
  };
}
