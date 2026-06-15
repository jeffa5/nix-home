{
  pkgs,
  lib,
  config,
  ...
}: let
  authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
  serverName = "filebrowser.home.jeffas.net";
  port = 8484;
  cfg = config.services.filebrowser;

  # Declarative filebrowser users. Authentication is delegated to Authelia
  # via the proxy auth header, so no filebrowser passwords are needed -
  # only permissions/scope are managed here.
  declarativeUsers = {
    andrew = {
      admin = true;
      scope = ".";
    };
    charlene = {
      admin = false;
      scope = "/charlene";
    };
  };

  userArgs = u:
    lib.escapeShellArgs [
      "--scope=${u.scope}"
      "--perm.admin=${lib.boolToString u.admin}"
      "--lockPassword"
    ];
in {
  # Override the filebrowser module's tmpfiles rule which would chown /local/files
  # to filebrowser:filebrowser:0700. File sorting ensures this wins (00- < filebrowser).
  systemd.tmpfiles.settings."00-local-files"."/local/files".d = {
    user = "root";
    group = "users";
    mode = "0755";
  };

  # Ensure each user's filebrowser scope directory exists with group access
  # for both that user and the filebrowser service user.
  systemd.tmpfiles.rules =
    lib.pipe declarativeUsers [
      (lib.filterAttrs (_: u: u.scope != "." && u.scope != "/"))
      (lib.mapAttrsToList (name: u: "d ${cfg.settings.root}${u.scope} 0750 ${name} ${name}-files -"))
    ];

  services.filebrowser = {
    enable = true;
    user = "filebrowser";
    settings = {
      address = "127.0.0.1";
      inherit port;
      root = "/local/files";
    };
  };

  users.users.filebrowser.extraGroups = ["family" "andrew-files" "charlene-files"];

  # Provision filebrowser's proxy auth (trusting Authelia's X-Remote-User
  # header) and declarative users on every start, since this state lives in
  # filebrowser's database rather than its config file.
  systemd.services.filebrowser-setup = {
    description = "Provision Filebrowser configuration and users";
    before = ["filebrowser.service"];
    requiredBy = ["filebrowser.service"];
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = cfg.group;
      StateDirectory = "filebrowser";
    };
    path = [cfg.package pkgs.coreutils];
    script = ''
      set -eu
      db=${lib.escapeShellArg cfg.settings.database}

      if [ ! -f "$db" ]; then
        filebrowser -d "$db" config init
      fi

      filebrowser -d "$db" config set \
        --auth.method=proxy \
        --auth.header=X-Remote-User \
        --root=${lib.escapeShellArg cfg.settings.root}

      ${lib.concatStrings (lib.mapAttrsToList (name: u: ''
        if filebrowser -d "$db" users find ${lib.escapeShellArg name} >/dev/null 2>&1; then
          filebrowser -d "$db" users update ${lib.escapeShellArg name} ${userArgs u}
        else
          filebrowser -d "$db" users add ${lib.escapeShellArg name} "$(head -c32 /dev/urandom | base64)" ${userArgs u}
        fi
      '')
      declarativeUsers)}
    '';
  };

  services.nginx.virtualHosts."Filebrowser" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
        include ${authelia-snippets.proxy};
        include ${authelia-snippets.authelia-authrequest};
      '';
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.authelia-location};
    '';
  };
}
