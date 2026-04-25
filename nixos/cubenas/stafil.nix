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
  unzip = lib.getExe pkgs.unzip;
  sevenzip = lib.getExe pkgs.p7zip;
  awk = lib.getExe' pkgs.gawk "awk";

  relSrc = "$$(echo $in | sed 's|${destination}||' | sed 's/#/%23/g')";
  imgLightbox = "<a href=\\\"#lightbox\\\"><img src=\\\"${relSrc}\\\" /></a><div id=\\\"lightbox\\\"><a href=\\\"#\\\"><img src=\\\"${relSrc}\\\" /></a></div>";
  pre = "echo \"<p><pre>$$(cat $in)</pre></p>\"";
  video = "echo \"<video controls src=\\\"$$(echo $in | sed 's|${destination}||' | sed 's/#/%23/g')\\\" /><pre>$$(cat \"$meta\")</pre>\"";
  audio = "echo \"<audio controls src=\\\"$$(echo $in | sed 's|${destination}||' | sed 's/#/%23/g')\\\" /><pre>$$(cat \"$meta\")</pre>\"";
  image = "echo \"${imgLightbox}<pre>$$(cat \"$meta\")</pre>$$(cat \"$gpslink\")\"";
  gpsExtra = {
    suffix = "gpslink";
    command = "${exiftool} -n -GPSLatitude -GPSLongitude -csv $in 2>/dev/null | ${awk} -F, 'NR==2 && \"$2\" != \"\" && \"$3\" != \"\" {printf \"<p><a href=&quot;https://www.openstreetmap.org/?mlat=%s&mlon=%s&zoom=15&quot; target=&quot;_blank&quot;>📍 View on OpenStreetMap</a></p>\", \"$2\", \"$3\"}' > $out";
    var = "gpslink";
  };
  exifMetaExtra = {
    suffix = "meta";
    command = "${exiftool} $in > $out || true";
    var = "meta";
  };
  jpgThumbExtra = {
    suffix = "thumb.jpg";
    command = "${magick} $in -auto-orient -thumbnail 250x90 -unsharp 0x.5 $out || cp $in $out";
  };
  videoThumbExtra = {
    suffix = "thumb.jpg";
    command = "${ffmpeg} -y -i $in -vframes 1 -vf scale=250:-1 $out || cp $in $out";
  };

  config = {
    source = source;
    destination = destination;
    staticFiles = ["${stafil-static}/style.css" "${stafil-static}/stafil.js"];
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
        command = pre;
        wrap = true;
      };
      ".csv" = {
        name = "csv";
        command = pre;
        wrap = true;
      };
      ".sh" = {
        name = "sh";
        command = pre;
        wrap = true;
      };
      ".log" = {
        name = "log";
        command = pre;
        wrap = true;
      };
      ".eml" = {
        name = "eml";
        command = pre;
        wrap = true;
      };
      ".pdf" = {
        name = "pdf";
        command = "echo \"<embed src=\\\"$$(echo $in | sed 's|${destination}||' | sed 's/#/%23/g')\\\" type=\"application/pdf\" frameBorder=\"0\" scrolling=\"auto\" height=\"100%\" width=\"100%\"></embed>\"";
        wrap = true;
      };
      ".md" = {
        name = "markdown";
        command = "${lib.getExe' pkgs.lowdown "lowdown"} $in";
        wrap = true;
      };
      ".json" = {
        name = "json";
        command = "echo \"<p><pre>$$(${lib.getExe pkgs.jq} . $in || cat $in)\\\"</pre></p>\"";
        wrap = true;
      };
      ".zip" = {
        name = "zip";
        command = "echo \"<p><pre>$$(${unzip} -l $in)</pre></p>\"";
        wrap = true;
      };
      ".tsv" = {
        name = "tsv";
        command = pre;
        wrap = true;
      };
      ".iso" = {
        name = "iso";
        command = "echo \"<p><pre>$$(${sevenzip} l $in)</pre></p>\"";
        wrap = true;
      };
      ".epub" = {
        name = "epub";
        command = "echo \"<p><pre>$$(${unzip} -l $in)</pre></p>\"";
        wrap = true;
      };
      ".htm" = {
        name = "htm";
        command = pre;
        wrap = true;
      };
      ".html" = {
        name = "html";
        command = pre;
        wrap = true;
      };
      ".py" = {
        name = "py";
        command = pre;
        wrap = true;
      };
      ".xml" = {
        name = "xml";
        command = pre;
        wrap = true;
      };
      ".svg" = {
        name = "svg";
        command = "echo \"<img src=\\\"${relSrc}\\\" />\"";
        wrap = true;
      };
      ".avif" = {
        name = "avif";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          jpgThumbExtra
        ];
      };
      ".jpg" = {
        name = "jpg";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          jpgThumbExtra
        ];
      };
      ".jpeg" = {
        name = "jpeg";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          jpgThumbExtra
        ];
      };
      ".png" = {
        name = "png";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          jpgThumbExtra
        ];
      };
      ".gif" = {
        name = "gif";
        command = "echo \"${imgLightbox}<pre>$$(cat \"$meta\")</pre>\"";
        wrap = true;
        extraRules = [
          exifMetaExtra
        ];
      };
      ".heic" = {
        name = "heic";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
        ];
      };
      ".nef" = {
        name = "nef";
        command = "echo \"<a href=\\\"#lightbox\\\"><img src=\\\"$$(echo \"$thumb\" | sed 's|${destination}||' | sed 's/#/%23/g')\\\" /></a><div id=\\\"lightbox\\\"><a href=\\\"#\\\"><img src=\\\"$$(echo \"$thumb\" | sed 's|${destination}||' | sed 's/#/%23/g')\\\" /></a></div><p><em>Preview is a thumbnail conversion from NEF — do not expect full quality.</em></p><pre>$$(cat \"$meta\")</pre>$$(cat \"$gpslink\")\"";
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          jpgThumbExtra
        ];
      };
      ".mp4" = {
        name = "mp4";
        command = video;
        wrap = true;
        extraRules = [
          exifMetaExtra
          videoThumbExtra
        ];
      };
      ".mov" = {
        name = "mov";
        command = video;
        wrap = true;
        extraRules = [
          exifMetaExtra
          videoThumbExtra
        ];
      };
      ".mp3" = {
        name = "mp3";
        command = audio;
        wrap = true;
        extraRules = [
          exifMetaExtra
        ];
      };
      ".flac" = {
        name = "flac";
        command = audio;
        wrap = true;
        extraRules = [
          exifMetaExtra
        ];
      };
      index = {
        name = "index";
        command = "${index} -thumb-extensions .png,.jpg,.jpeg,.gif,.mp4,.mov -thumb-suffix thumb.jpg -root ${source} -dir $in";
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
    extraGroups = ["family"];
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
      time ${lib.getExe pkgs.ninja} -C ${destination} -t cleandead
      time ${lib.getExe pkgs.lychee} --offline --root-dir '${destination}' '${destination}/**/*.html'
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
      OnCalendar = "*-*-* 12:00:00";
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
