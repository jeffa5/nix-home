pkgs: {
  enable = true;
  package = pkgs.firefox-wayland;
  profiles = {
    andrew = {
      settings = {
        "browser.startup.page" = 3;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
      };
    };
  };
}
