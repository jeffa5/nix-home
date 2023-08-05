{...}: {
  programs.ssh = {
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
          # forward kerberos tickets, requires `kinit -f ...`
          GSSAPIDelegateCredentials = "yes";
        };
      };
      "quoth" = {
        hostname = "quoth.cl.cam.ac.uk";
        user = "apj39";
        extraOptions = {
          GSSAPIAuthentication = "yes";
          # forward kerberos tickets, requires `kinit -f ...`
          GSSAPIDelegateCredentials = "yes";
        };
      };
      "caelum*" = {
        user = "apj39";
      };
      "azure-dev" = {
        user = "apj39";
        hostname = "52.188.86.42";
      };
      "cerulean" = {
        user = "apj39";
        hostname = "172.174.123.138";
      };

      "rosebud" = {
        user = "root";
        hostname = "95.217.130.208";
      };
    };
  };
}
