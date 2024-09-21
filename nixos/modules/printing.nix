{pkgs, ...}: {
  services.printing = {
    enable = true;
    # clientConf = "ServerName cups-serv.cl.cam.ac.uk";
    drivers = [pkgs.gutenprint pkgs.hplip];
  };
}
