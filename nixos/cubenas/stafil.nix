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
  ffmpeg = lib.getExe pkgs.ffmpeg;

  config = {
    source = source;
    destination = destination;
    staticFiles = ["${stafil-static}/style.css"];
    staticDir = "static";
    search = {
      command = lib.getExe' pkgs.stafil "stafil-search";
    };
    wrap = {
      command = " | ${wrap} -root ${destination} -path $out -prev=\"$prev\" -next=\"$next\" -before ${stafil-templates}/head.html,${stafil-templates}/header.html -after ${stafil-templates}/footer.html,${stafil-templates}/foot.html > $out";
      deps = ["${stafil-templates}/head.html" "${stafil-templates}/header.html" "${stafil-templates}/footer.html" "${stafil-templates}/foot.html"];
    };
    rules = {
      ".txt" = {
        name = "text";
        command = "echo \"<p><pre>$$(cat '$in')</pre></p>\"";
        wrap = true;
      };
      ".csv" = {
        name = "csv";
        command = "echo \"<p><pre>$$(cat '$in')</pre></p>\"";
        wrap = true;
      };
      ".sh" = {
        name = "sh";
        command = "echo \"<p><pre>$$(cat '$in')</pre></p>\"";
        wrap = true;
      };
      ".log" = {
        name = "log";
        command = "echo \"<p><pre>$$(cat '$in')</pre></p>\"";
        wrap = true;
      };
      ".eml" = {
        name = "eml";
        command = "echo \"<p><pre>$$(cat '$in')</pre></p>\"";
        wrap = true;
      };
      ".pdf" = {
        name = "pdf";
        command = "echo \"<embed src=\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\" type=\"application/pdf\" frameBorder=\"0\" scrolling=\"auto\" height=\"100%\" width=\"100%\"></embed>\"";
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
        command = "echo \"<img src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
          {
            suffix = "thumb";
            command = "${magick} $in -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out || cp $in $out";
          }
        ];
      };
      ".jpeg" = {
        name = "jpeg";
        command = "echo \"<img src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
          {
            suffix = "thumb";
            command = "${magick} $in -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out || cp $in $out";
          }
        ];
      };
      ".png" = {
        name = "png";
        command = "echo \"<img src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
          {
            suffix = "thumb";
            command = "${magick} $in -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out || cp $in $out";
          }
        ];
      };
      ".gif" = {
        name = "gif";
        command = "echo \"<img src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
        ];
      };
      ".heic" = {
        name = "heic";
        command = "echo \"<img src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
        ];
      };
      ".nef" = {
        name = "nef";
        command = "echo \"<pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
        ];
      };
      ".mp4" = {
        name = "mp4";
        command = "echo \"<video controls src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
          {
            suffix = "thumb";
            command = "${ffmpeg} -y -i $in -ss 00:00:01 -vframes 1 -vf scale=250:-1 $out || cp $in $out";
          }
        ];
      };
      ".mov" = {
        name = "mov";
        command = "echo \"<video controls src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
          {
            suffix = "thumb";
            command = "${ffmpeg} -y -i $in -ss 00:00:01 -vframes 1 -vf scale=250:-1 $out || cp $in $out";
          }
        ];
      };
      ".mp3" = {
        name = "mp3";
        command = "echo \"<audio controls src=\\\"$$(echo '$in' | sed 's#${destination}\\(.*\\)#\\1#')\\\" /><pre>$$(cat '$meta')</pre>\"";
        wrap = true;
        extraRules = [
          {
            suffix = "meta";
            command = "${exiftool} $in > $out";
            var = "meta";
            appendSuffix = true;
          }
        ];
      };
      index = {
        name = "index";
        command = "${index} -thumb-extensions .png,.jpg,.jpeg,.gif,.mp4,.mov -root ${source} -dir $in";
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

  systemd.services.stafil = let
    concurrency = "8";
  in {
    enable = true;
    description = "Generate stafil file browser";
    script = ''
      set -ex
      time ${lib.getExe' pkgs.stafil "stafil-configure"} --config-file ${configFile} --search-paths ${destination}/search.paths --concurrency ${concurrency} >${destination}/build.ninja
      time ${lib.getExe pkgs.ninja} -C ${destination} -j ${concurrency} -k 0
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
    restartIfChanged = false;
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
