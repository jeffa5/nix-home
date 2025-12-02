{config, ...}: {
  programs.nushell = {
    enable = true;

    environmentVariables = config.home.sessionVariables;

    settings = {
      show_banner = false;
      edit_mode = "vi";
      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };
    };
  };
}
