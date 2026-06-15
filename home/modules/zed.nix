{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;
    extraPackages = [
      pkgs.claude-code
    ];
  };
}
