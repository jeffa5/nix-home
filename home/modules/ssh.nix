{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        Hostname = "ssh.github.com";
        Port = 443;
      };
    };
  };
}
