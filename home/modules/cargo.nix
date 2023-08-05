{pkgs, ...}: {
  home.file = {
    ".cargo/config".text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      [net]
      git-fetch-with-cli = true
    '';
  };
}
