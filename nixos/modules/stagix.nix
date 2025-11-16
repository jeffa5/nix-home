{
  config,
  pkgs,
  lib,
  ...
}: let
  stagix-repo = lib.getExe' pkgs.stagix "stagix-repo";
  stagix-index = lib.getExe' pkgs.stagix "stagix-index";
  stagix-pages = lib.getExe' pkgs.stagix "stagix-pages";


  stagix-index-script = {
    gitHost,
    gitReposDir,
    gitWebDir,
    gitReposUrl,
    gitPagesUrl,
  }: ''
    set -ex

    # Set some default values if missing
    for dir in ${gitReposDir}/*; do
      echo "git://${gitHost}/''${dir#${cfg.gitRoot}/}" > $dir/url
      if [ ! -f $dir/owner ]; then
        echo "Andrew Jeffery <dev@jeffas.net>" > $dir/owner
      fi
    done

    cd ${gitWebDir}

    # - Makes index for repositories in a single directory.
    # - Makes static pages for each repository directory.
    #
    # NOTE, things to do manually (once) before running this script:
    # - copy style.css, logo.png and favicon.png manually, a style.css example
    #   is included.
    #
    # - write clone URL, for example "git://git.codemadness.org/dir" to the "url"
    #   file for each repo.
    # - write owner of repo to the "owner" file.
    # - write description in "description" file.
    #
    # Usage:
    # - mkdir -p htmldir && cd htmldir
    # - sh example_create.sh

    # path must be absolute.
    reposdir="${gitReposDir}"
    curdir="${gitWebDir}"

    # make index.
    ${stagix-index} --out-dir "''${curdir}" --repos-url "https://${gitReposUrl}" --pages-url "https://${gitPagesUrl}" --stylesheet ${pkgs.stagix}/share/doc/stagix/style.css --logo ${pkgs.stagix}/share/doc/stagix/logo.png --favicon ${pkgs.stagix}/share/doc/stagix/favicon.png "''${reposdir}/"*/

    # make files per repo.
    for dir in "''${reposdir}/"*/; do
    	# strip .git suffix.
    	r=$(basename "''${dir}")
    	d=$(basename "''${dir}" ".git")
    	echo "''${d}..."

    	mkdir -p "''${curdir}/''${d}"
    	cd "''${curdir}/''${d}" || continue
    	${stagix-repo} "''${reposdir}/''${r}"

    	# symlinks
    	ln -sf log.html index.html
    	ln -sf ../style.css style.css
    	ln -sf ../logo.png logo.png
    	ln -sf ../favicon.png favicon.png

    	echo "done"
    done
  '';
  stagix-index-service = {
    gitHost,
    gitReposDir,
    gitWebDir,
    gitReposUrl,
    gitPagesUrl,
  }: {
    enable = true;
    description = "Generate stagix repos";
    script = stagix-index-script {
      inherit
        gitHost
        gitReposDir
        gitWebDir
        gitReposUrl
        gitPagesUrl
        ;
    };
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = cfg.group;
    };
    wantedBy = ["multi-user.target"];
  };
  stagix-pages-service = {
    gitPagesDir,
    gitPagesWorkingDir,
    gitReposDir,
    gitReposUrl,
    gitPagesUrl,
  }: {
    enable = true;
    description = "Generate stagix pages";
    script = ''
      set -ex

      ${stagix-pages} --out-dir "${gitPagesDir}" --working-dir "${gitPagesWorkingDir}" --index --repos-url "https://${gitReposUrl}" --pages-url "https://${gitPagesUrl}" --stylesheet ${pkgs.stagix}/share/doc/stagix/style.css --logo ${pkgs.stagix}/share/doc/stagix/logo.png --favicon ${pkgs.stagix}/share/doc/stagix/favicon.png "${gitReposDir}/"*/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = cfg.group;
    };
    wantedBy = ["multi-user.target"];
  };
  timerConfig = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
    };
  };

  gitHost = "git.${cfg.hostName}";
  pagesHost = "pages.${cfg.hostName}";

  mkServicesConfig = name: {path}: let
    gitWebDir = "${cfg.gitRoot}-www/${path}";
    gitPagesDir = "${cfg.gitRoot}-pages/${path}";
    gitReposDir = "${cfg.gitRoot}/${path}";
  in {
    "stagix-index-${path}" = stagix-index-service {
      inherit gitHost gitWebDir gitReposDir;
      gitReposUrl = "${path}-${gitHost}";
      gitPagesUrl = "${path}-${pagesHost}";
    };

    "stagix-pages-${path}" = stagix-pages-service {
      inherit gitPagesDir gitReposDir;
      gitPagesWorkingDir = "${cfg.gitRoot}-pages-workdir/${path}";
      gitReposUrl = "${path}-${gitHost}";
      gitPagesUrl = "${path}-${pagesHost}";
    };
  };

  mkTimersConfig = name: {path}: {
    "stagix-index-${path}" = timerConfig;

    "stagix-pages-${path}" = timerConfig;
  };

  mkNginxConfig = name: {path}: let
    gitWebDir = "${cfg.gitRoot}-www/${path}";
    gitPagesDir = "${cfg.gitRoot}-pages/${path}";
    authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
    serveFilesAt = {
      host,
      root,
    }: {
      serverName = host;
      locations."/" = {
        root = root;
        extraConfig = ''
          include ${authelia-snippets.proxy};
          include ${authelia-snippets.authelia-authrequest};
        '';
      };
      forceSSL = true;
      useACMEHost = cfg.hostName;
      extraConfig = ''
        include ${authelia-snippets.authelia-location};
      '';
    };
  in {
    "Git - ${name}" = serveFilesAt {
      host = "${path}-${gitHost}";
      root = gitWebDir;
    };

    "Git Pages - ${name}" = serveFilesAt {
      host = "${path}-${pagesHost}";
      root = gitPagesDir;
    };

    # TODO: set up git post receive hook to run stagix for that repo
  };

  cfg = config.services.stagix;
in {
  options.services.stagix = {
    enable = lib.mkEnableOption "stagix";

    gitRoot = lib.mkOption {
      type = lib.types.str;
    };

    hostName = lib.mkOption {
      type = lib.types.str;
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "git";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "git";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.str;
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = (
      lib.mergeAttrsList (
        builtins.attrValues (
          builtins.mapAttrs mkServicesConfig cfg.locations
        )
      )
    );

    systemd.timers = (
      lib.mergeAttrsList (
        builtins.attrValues (
          builtins.mapAttrs mkTimersConfig cfg.locations
        )
      )
    );

    services.nginx.virtualHosts = (
      lib.mergeAttrsList (
        builtins.attrValues (
          builtins.mapAttrs mkNginxConfig cfg.locations
        )
      )
    );
  };
}
