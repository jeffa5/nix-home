{
  pkgs,
  lib,
  ...
}: let
  gitProjDir = "/local/git";
  gitWebDir = "/local/git-www";
  stagit = lib.getExe' pkgs.stagit "stagit";
  stagit-index = lib.getExe' pkgs.stagit "stagit-index";
in {
  systemd.services.stagit-index = {
    enable = true;
    description = "Generate stagit repos";
    script = ''
      set -ex

      cp ${pkgs.stagit}/share/doc/stagit/style.css ${gitWebDir}/style.css
      cp ${pkgs.stagit}/share/doc/stagit/logo.png ${gitWebDir}/logo.png
      cp ${pkgs.stagit}/share/doc/stagit/favicon.png ${gitWebDir}/favicon.png

      # for dir in ${gitProjDir}/*; do
      #   base=$(basename $dir)
      #   if [ ! -f $dir/url ]; then
      #     echo "git://git.home.jeffas.net/$base" > $dir/url
      #   fi
      #   if [ ! -f $dir/owner ]; then
      #     echo "Andrew Jeffery <dev@jeffas.net>" > $dir/owner
      #   fi
      #   mkdir -p ${gitWebDir}/$base
      #   cd ${gitWebDir}/$base
      #   ${stagit} ${gitProjDir}/$base
      #   ln -sf log.html index.html
      #   ln -sf ../style.css style.css
      #   ln -sf ../logo.png logo.png
      #   ln -sf ../favicon.png favicon.png
      # done
      # cd ${gitWebDir}
      # ${stagit-index} ${gitProjDir}/* > index.html

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
      reposdir="${gitProjDir}"
      curdir="${gitWebDir}"

      # make index.
      ${stagit-index} "''${reposdir}/"*/ > "''${curdir}/index.html"

      # make files per repo.
      for dir in "''${reposdir}/"*/; do
      	# strip .git suffix.
      	r=$(basename "''${dir}")
      	d=$(basename "''${dir}" ".git")
      	echo "''${d}..."

      	mkdir -p "''${curdir}/''${d}"
      	cd "''${curdir}/''${d}" || continue
      	${stagit} -c ".cache" -u "https://git.home.jeffas.net/$d/" "''${reposdir}/''${r}"

      	# symlinks
      	ln -sf log.html index.html
      	ln -sf ../style.css style.css
      	ln -sf ../logo.png logo.png
      	ln -sf ../favicon.png favicon.png

      	echo "done"
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "git";
      Group = "git";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.timers.stagit-index = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
    };
  };

  services.nginx.virtualHosts."Git" = {
    serverName = "git.home.jeffas.net";
    locations."/" = {
      root = gitWebDir;
    };
  };

  # TODO: set up git post receive hook to run stagit for that repo
  # TODO: set up nginx to serve static files in /local/git-www dir
}
