{...}: {
  services.mako = {
    enable = true;
    settings = {
      backgroundColor = "#282828";
      borderSize = 4;
      defaultTimeout = 10000;
      font = "hack 12";
      height = 200;
      textColor = "#ebdbb2";
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
