{...}: {
  hardware.sane.enable = true;
  users.users.andrew.extraGroups = ["scanner" "lp"];
}
