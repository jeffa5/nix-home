{pkgs, ...}: {
  programs.claude-code = {
    enable = true;
    settings = {
      hooks = {
        user-prompt = "${pkgs.libnotify}/bin/notify-send 'Claude Code' 'Input needed' --urgency=normal";
      };
    };
  };
}
