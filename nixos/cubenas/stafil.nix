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
  magick = lib.getExe' pkgs.imagemagick "magick";

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
      ".csv" = {
        name = "csv";
        command = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
        wrap = true;
      };
      ".sh" = {
        name = "sh";
        command = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
        wrap = true;
      };
      ".log" = {
        name = "log";
        command = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
        wrap = true;
      };
      ".eml" = {
        name = "eml";
        command = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
        wrap = true;
      };
      ".pdf" = {
        name = "pdf";
        command = "echo \"<embed src=\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\" type=\"application/pdf\" frameBorder=\"0\" scrolling=\"auto\" height=\"100%\" width=\"100%\"></embed>\"";
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
        extraRules = [
          {
            suffix = "thumb";
            command = "cp $in $out && ${magick} -define jpeg:size=500x180 $out -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out";
          }
        ];
      };
      ".jpeg" = {
        name = "jpeg";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "thumb";
            command = "cp $in $out && ${magick} -define jpeg:size=500x180 $out -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out";
          }
        ];
      };
      ".png" = {
        name = "png";
        command = "echo \"<img src=\\\"$$(echo $in | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(${exiftool} $in)</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "thumb";
            command = "cp $in $out && ${magick} -define jpeg:size=500x180 $out -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out";
          }
        ];
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
        command = "${index} -thumb-extensions .png,.jpg,.jpeg,.gif -root ${source} -dir $in";
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
    root = "${destination}/";
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.proxy};
      include ${authelia-snippets.authelia-authrequest};
      include ${authelia-snippets.authelia-location};
    '';
  };

  # let nginx access the git repos
  users.users.nginx.extraGroups = [group];
}
