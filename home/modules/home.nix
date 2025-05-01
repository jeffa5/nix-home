{username}: {...}: let
  homeDirectory = "/home/${username}";
in {
  home = {
    inherit homeDirectory username;
    sessionPath = ["${homeDirectory}/.cargo/bin"];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "nvim";
    };

    stateVersion = "21.11";
  };
  programs.home-manager.enable = true;
}
