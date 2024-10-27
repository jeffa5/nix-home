{...}: let
  port = 1883;
in {
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = ["pattern readwrite #"];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        port = port;
      }
    ];
  };

  # wait for storage
  systemd.services.mosquitto = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };
}
