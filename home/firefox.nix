pkgs: {
  enable = true;
  package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    forceWayland = true;
    extraPolicies = {
      ExtensionSettings = { };
    };
  };
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
