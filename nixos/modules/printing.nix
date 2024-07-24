{...}: {
  services.printing = {
    enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };
}
