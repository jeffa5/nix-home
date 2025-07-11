{
  pkgs,
  ...
}: {
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/var/lib/git-server";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODXbDACWjYCOv+NxgC6Lzi3hx4+hdpHYaPyWDcOuyWU andrew@x1c6"
    ];
    packages = [
      pkgs.git
    ];
  };

  users.groups.git = {};

  services.openssh = {
    enable = true;
    extraConfig = ''
      Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no
    '';
  };
}
