{
  pkgs,
  lib,
  ...
}: let
  homeDir = "/var/lib/git-server";
in {
  environment.systemPackages = [pkgs.git];

  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = homeDir;
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

  systemd.tmpfiles.rules = [
    "L+ ${homeDir}/git-shell-commands/git-lfs-transfer - - - - ${lib.getExe pkgs.git-lfs-transfer}"
  ];

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
