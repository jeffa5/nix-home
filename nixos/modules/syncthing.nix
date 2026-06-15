{users ? []}: {
  pkgs,
  lib,
  ...
}: let
  authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};

  guiPort = i: 8384 + i;
  syncPort = i: 22000 + i;

  mkSyncthingService = i: username: {
    name = "syncthing-${username}";
    value = {
      description = "Syncthing for ${username}";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      # Syncthing defaults new configs to listen on 22000 (TCP+QUIC); each
      # user needs a unique sync port, so assign one on first-ever start.
      preStart = ''
        config=/local/syncthing/${username}/config.xml
        if [ -f "$config" ] && grep -q '<listenAddress>default</listenAddress>' "$config"; then
          ${pkgs.gnused}/bin/sed -i \
            's|<listenAddress>default</listenAddress>|<listenAddress>tcp://0.0.0.0:${toString (syncPort i)}</listenAddress>\n        <listenAddress>quic://0.0.0.0:${toString (syncPort i)}</listenAddress>\n        <listenAddress>dynamic+https://relays.syncthing.net/endpoint</listenAddress>|' \
            "$config"
        fi
        # Reverse-proxied via nginx with its own Host header, so syncthing's
        # own Host check must be disabled (see syncthing docs on reverse proxies).
        if [ -f "$config" ] && ! grep -q '<insecureSkipHostcheck>' "$config"; then
          ${pkgs.gnused}/bin/sed -i \
            's|</gui>|    <insecureSkipHostcheck>true</insecureSkipHostcheck>\n    </gui>|' \
            "$config"
        fi
      '';
      serviceConfig = {
        User = username;
        Group = "${username}-files";
        ExecStart = lib.escapeShellArgs [
          "${pkgs.syncthing}/bin/syncthing"
          "--no-browser"
          "--home=/local/syncthing/${username}"
          "--gui-address=127.0.0.1:${toString (guiPort i)}"
        ];
        Restart = "on-failure";
        RestartSec = "10s";
        SuccessExitStatus = [0 1];
      };
    };
  };

  # nginx map entries: "$user -> upstream" for routing
  upstreamEntries = lib.concatStringsSep "\n    " (
    lib.imap0 (i: u: "${u} http://127.0.0.1:${toString (guiPort i)};") users
  );
in {
  systemd.services = lib.listToAttrs (lib.imap0 mkSyncthingService users);

  # Only create syncthing config dirs; /local/files/<username>/ dirs already exist.
  # /local/syncthing itself must stay traversable so each user can reach their own subdir.
  systemd.tmpfiles.rules =
    ["d /local/syncthing 0755 root root -"]
    ++ map (username:
      "d /local/syncthing/${username} 0700 ${username} users -")
    users;

  networking.firewall.allowedTCPPorts = lib.imap0 (i: _: syncPort i) users;
  networking.firewall.allowedUDPPorts = lib.imap0 (i: _: syncPort i) users ++ [21027];

  environment.systemPackages = [pkgs.syncthing];

  # $user is set by the authelia-authrequest snippet after the auth subrequest.
  # This map routes each authenticated user to their own syncthing instance.
  services.nginx.commonHttpConfig = ''
    map $user $syncthing_upstream {
      ${upstreamEntries}
    }
  '';

  services.nginx.virtualHosts."Syncthing" = {
    serverName = "syncthing.home.jeffas.net";
    locations."/" = {
      proxyPass = "$syncthing_upstream";
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
