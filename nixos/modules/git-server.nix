{
  pkgs,
  lib,
  ...
}: let
  homeDir = "/local/git";

  new-git-repo = pkgs.writeShellScriptBin "new-git-repo" ''
    read -p "Name: " name
    read -p "Description: " description

    mkdir "$name.git"
    cd "$name.git"
    ${lib.getExe pkgs.git} init --bare .
    echo "$description" > "description"

    cp --update=none hooks/post-update.sample hooks/post-update
    chmod a+x hooks/post-update

    chown -R git:git .
  '';
in {
  environment.systemPackages = [pkgs.git new-git-repo];

  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = homeDir;
    homeMode = "0750";
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

  services.nginx.virtualHosts."Git" = {
    serverName = "git.home.jeffas.net";
    locations."/" = {
      # serve the nice web UI
      root = "${homeDir}-www/public-external";
      tryFiles = "$uri $uri/ @git";
    };
    locations."@git" = {
      # fallback to serving the backing git repo
      root = "${homeDir}/public";
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };

  # let nginx access the git repos
  users.users.nginx.extraGroups = ["git"];
}
