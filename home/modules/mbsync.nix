{pkgs, ...}: {
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    postExec = "${pkgs.mu}/bin/mu index && ${pkgs.mu}/bin/mu cfind > ~/contacts/list";
  };
}
