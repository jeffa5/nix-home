{
  personal = {
    primary = true;
    address = "andrewjeffery97@gmail.com";
    # host = "mail.google.com";
    flavor = "gmail.com";
    imap = {};
    smtp = {};
  };
  general = {
    primary = false;
    address = "theaiaj.general@gmail.com";
    flavor = "gmail.com";
    imap = {};
    smtp = {};
  };
  jeffasio = {
    primary = false;
    address = "andrew@jeffas.io";
    flavor = "plain";
    imap = {};
    smtp = {};
  };
  jeffasnet = {
    primary = false;
    address = "andrew@jeffas.net";
    flavor = "plain";
    imap = {
      host = "imap.migadu.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "smtp.migadu.com";
      port = 465;
      tls = {
        enable = true;
      };
    };
  };
  devio = {
    primary = false;
    address = "dev@jeffas.io";
    flavor = "plain";
    imap = {};
    smtp = {};
  };
  devnet = {
    primary = false;
    address = "dev@jeffas.net";
    flavor = "plain";
    imap = {
      host = "imap.migadu.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "smtp.migadu.com";
      port = 465;
      tls = {
        enable = true;
      };
    };
  };
  joint = {
    primary = false;
    address = "acjt_andrew@jeffas.net";
    flavor = "plain";
    imap = {
      host = "imap.migadu.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "smtp.migadu.com";
      port = 465;
      tls = {
        enable = true;
      };
    };
  };
}
