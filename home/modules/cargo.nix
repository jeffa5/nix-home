{pkgs, ...}: {
  home.file = {
    ".cargo/config.toml".text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      [net]
      git-fetch-with-cli = true
    '';
  };
}
