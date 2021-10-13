{
  enable = true;
  matchBlocks = {
    "github.com" = {
      hostname = "ssh.github.com";
      port = 443;
    };
    "binky" = {
      hostname = "binky.cl.cam.ac.uk";
      user = "apj39";
      extraOptions = {
        GSSAPIAuthentication = "yes";
      };
    };
    "caelum*" = {
      user = "apj39";
    };
  };
}
