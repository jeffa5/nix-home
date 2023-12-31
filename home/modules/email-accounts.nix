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
  jeffas = {
    primary = false;
    address = "andrew@jeffas.io";
    flavor = "plain";
    imap = {
      host = "mail.privateemail.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "mail.privateemail.com";
      port = 465;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
  };
  dev = {
    primary = false;
    address = "dev@jeffas.io";
    flavor = "plain";
    imap = {
      host = "mail.privateemail.com";
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      host = "mail.privateemail.com";
      port = 465;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
  };
}
