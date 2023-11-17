{...}: {
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
  };
}
