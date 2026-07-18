{...}: {
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles = {
      andrew = {
        settings = {
          "browser.startup.page" = 3;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;
          "browser.sessionstore.max_tabs_undo" = 250;
          "browser.sessionstore.max_windows_undo" = 10;
        };
      };
    };
  };
}
