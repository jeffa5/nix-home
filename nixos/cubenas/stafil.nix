{pkgs, ...}: let
  lib = pkgs.lib;
  user = "stafil";
  group = "stafil";

  stafil-templates = "${pkgs.stafil}/share/doc/stafil/templates";
  stafil-static = "${pkgs.stafil}/share/doc/stafil/static";

  source = "/local/files";
  destination = "/local/files-www";

  exiftool = lib.getExe pkgs.exiftool;
  wrap = lib.getExe' pkgs.stafil "stafil-wrap";
  index = lib.getExe' pkgs.stafil "stafil-index";

  config = {
    source = source;
    destination = destination;
    staticFiles = ["${stafil-static}/style.css"];
    staticDir = "static";
    wrap = {
      command = " | ${wrap} -root ${destination} -path $out -before ${stafil-templates}/head.html,${stafil-templates}/header.html -after ${stafil-templates}/footer.html,${stafil-templates}/foot.html > $out";
      deps = ["${stafil-templates}/head.html" "${stafil-templates}/header.html" "${stafil-templates}/footer.html" "${stafil-templates}/foot.html"];
    };
    rules = {
      ".txt" = {
        name = "text";
        command = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
        wrap = true;
      };
      ".md" = {
        name = "markdown";
        command = "${lib.getExe' pkgs.lowdown "lowdown"} $in";
        wrap = true;
      };
      ".json" = {
        name = "json";
        command = "echo \"<p><pre>$$(${lib.getExe pkgs.jq} . $in)\\\"</pre></p>\"";
        wrap = true;
      };
      ".jpg" = {
        name = "jpg";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".jpeg" = {
        name = "jpeg";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".png" = {
        name = "png";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".gif" = {
        name = "gif";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".heic" = {
        name = "heic";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".mp4" = {
        name = "mp4";
        command = "echo \"<video controls src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".mov" = {
        name = "mov";
        command = "echo \"<video controls src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      ".mp3" = {
        name = "mp3";
        command = "echo \"<audio controls src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
      };
      index = {
        name = "index";
        command = "${index} -root ${source} -dir $in";
        wrap = true;
      };
    };
  };

  configJson = builtins.toJSON config;
  configFile = pkgs.writeTextFile {
    name = "stafil-config";
    text = configJson;
  };
in {
  environment.systemPackages = [
    pkgs.ninja
    pkgs.stafil
    pkgs.jq
  ];

  users.users.${user} = {
    isSystemUser = true;
    group = group;
  };

  users.groups.${group} = {};

  systemd.services.stafil = {
    enable = true;
    description = "Generate stafil file browser";
    script = ''
      set -ex
      ${lib.getExe' pkgs.stafil "stafil-configure"} --config-file ${configFile} >${destination}/build.ninja
      ${lib.getExe pkgs.ninja} -C ${destination}
    '';
    environment = {
      SHELL = lib.getExe pkgs.bash;
    };
    path = [pkgs.bash];
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = group;
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.timers.stafil = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
    };
  };

  services.nginx.virtualHosts."Files WWW" = let
    authelia-snippets = import ../modules/authelia-snippets.nix {inherit pkgs;};
  in {
    serverName = "files.home.jeffas.net";
    root = "/local/files-www/";
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      autoindex on;
      include ${authelia-snippets.proxy};
      include ${authelia-snippets.authelia-authrequest};
      include ${authelia-snippets.authelia-location};
    '';
  };

  # let nginx access the git repos
  users.users.nginx.extraGroups = [group];
}
