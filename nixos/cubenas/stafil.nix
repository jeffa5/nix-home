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
  tagsExtra = {
    suffix = "tags";
    command = "${exiftool} -j $in 2>/dev/null | ${lib.getExe pkgs.jq} -r '.[0].Keywords // empty | if type==\"array\" then .[] else split(\",\")[] end | ltrimstr(\" \") | rtrimstr(\" \")' > $out; true";
    tags = true;
  };

  classifierPython = pkgs.python3.withPackages (ps: [
    ps.onnxruntime
    ps.pillow
    ps.numpy
  ]);
  mobilenetModel = pkgs.fetchurl {
    url = "https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-12.onnx";
    hash = "sha256-wMP3bZP6P9ZYBlKkVhhhiiIPztGLq/ZXdO0WneBDKtU=";
  };
  imagenetLabels = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt";
    hash = "sha256-HzhuDRy24oucLaxlHD3qaAHpitG0GhTOa7Ggk9cgafU=";
  };
  classifierScript = pkgs.writeScript "stafil-classify" ''
    #!${classifierPython}/bin/python3
    import sys
    import numpy as np
    from PIL import Image
    import onnxruntime as ort

    THRESHOLD = 0.05
    TOP_K = 5

    def softmax(x):
        e = np.exp(x - np.max(x))
        return e / e.sum()

    def preprocess(path):
        img = Image.open(path).convert('RGB').resize((224, 224), Image.BILINEAR)
        arr = np.array(img, dtype=np.float32) / 255.0
        arr = (arr - [0.485, 0.456, 0.406]) / [0.229, 0.224, 0.225]
        return arr.transpose(2, 0, 1)[np.newaxis].astype(np.float32)

    def main(in_path, out_path):
        with open('${imagenetLabels}') as f:
            labels = [line.strip() for line in f]

        sess = ort.InferenceSession('${mobilenetModel}', providers=['CPUExecutionProvider'])
        inp_name = sess.get_inputs()[0].name

        img = preprocess(in_path)
        (logits,) = sess.run(None, {inp_name: img})
        probs = softmax(logits[0])

        top = sorted(range(len(probs)), key=lambda i: probs[i], reverse=True)[:TOP_K]
        tags = [labels[i] for i in top if probs[i] >= THRESHOLD]

        with open(out_path, 'w') as f:
            f.write('\n'.join(tags))

    if __name__ == '__main__':
        try:
            main(sys.argv[1], sys.argv[2])
        except Exception:
            open(sys.argv[2], 'w').close()
  '';
  tagsMLExtra = {
    suffix = "ml-tags";
    command = "${classifierScript} $in $out; true";
    tags = true;
  };

  config = {
    source = source;
    destination = destination;
    tags = {
      dir = "tags";
    };
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
          tagsExtra
          tagsMLExtra
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
          tagsExtra
          tagsMLExtra
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
          tagsExtra
          tagsMLExtra
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
          tagsExtra
          tagsMLExtra
        ];
      };
      ".gif" = {
        name = "gif";
        command = "echo \"${imgLightbox}<pre>$$(cat \"$meta\")</pre>\"";
        wrap = true;
        extraRules = [
          exifMetaExtra
          tagsExtra
          tagsMLExtra
        ];
      };
      ".heic" = {
        name = "heic";
        command = image;
        wrap = true;
        extraRules = [
          exifMetaExtra
          gpsExtra
          tagsExtra
          tagsMLExtra
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
          tagsExtra
          tagsMLExtra
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
