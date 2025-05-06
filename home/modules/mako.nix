{...}: {
  services.mako = {
    enable = true;
    settings = {
      background-color = "#282828";
      border-size = 4;
      default-timeout = 10000;
      font = "hack 12";
      height = 200;
      text-color = "#ebdbb2";
      width = 400;
      format = "<b><u>%a</u></b>\\n<b>%s</b>\\n%b";
    };
    criteria = {
      "hidden" = {
        border-color = "#83a598";
      };
      "urgency=low" = {
        border-color = "#b8bb26";
      };
      "urgency=normal" = {
        border-color = "#fabd2f";
      };
      "urgency=high" = {
        border-color = "#fb4934";
      };
      "mode=dnd" = {
        invisible = "1";
      };
    };
  };
}
