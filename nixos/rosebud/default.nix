{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "rosebud";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDd41siljusZNnvscLFujgkNiXM/qFpcaMdKwxC0GEm+980XSfH6P+FyUcuGntnrHcUExjhm2L6JoHbsz992PyGSqlb4mtcdwqdbCuTJWGo5lk4JJu/s74m1UGwGvSTwgv/R4UmBWCGfsJFdE8t1Oc2wmsHDbI6xRKyBnG8/zl3NFX7jKw0Ayz2LWIJdqW/FqRmOi6VdCcglRRmh1naAVcElBf2o/l4DRlvngIwOkhOHe3uy/foCVXW4/YvsIXsxuXlWrgGDz7MtR3ZBqqaSM4ORxLBG4Gpy80AlISRYru1FXWWG0S1rvs9jw6qcBC0xCfA+3fhoykvytuA/gjOxJLOQK5r8otUZxi72DveAEbr5RTk3w0PfUeyjGJnXZIpD9h7jLUFpDZJQn8Ln1Iw2edPnb4rdky0vLvYThbOPK+qhuUO2l4RuhDnfncXJYX5RMyXi+LrxSYx62mUv/nZbz1L6XVYAN3nZijtZHFXw4Rg9m1JZbFB0bkLbowW6q4lEL0=''
  ];
}
