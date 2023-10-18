{...}: {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";

      statusbar-home-tilde = true;

      completion-bg = "#282828";
      completion-fg = "#ebdbb2";

      completion-group-bg = "#1d2021";
      completion-group-fg = "#ebdbb2";

      completion-highlight-bg = "#98971a";
      completion-highlight-fg = "#282828";

      inputbar-bg = "#282828";
      inputbar-fg = "#98971a";

      notification-error-bg = "#cc241d";
      notification-error-fg = "#ebdbb2";

      notification-warning-bg = "#fabd2f";
      notification-warning-fg = "#282828";

      statusbar-bg = "#1d2021";
      statusbar-fg = "#ebdbb2";

      default-bg = "#282828";
      default-fg = "#ebdbb2";
    };
  };
}
