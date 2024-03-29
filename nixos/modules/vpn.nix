{
  pkgs,
  config,
  ...
}: {
  networking.networkmanager.enableStrongSwan = true;
  environment.systemPackages = with pkgs; [
    strongswan
  ];

  services = {
    # Check status at
    # https://myip.uis.cam.ac.uk/
    strongswan = {
      enable = true;
      # Passwords set up as per https://help.uis.cam.ac.uk/service/network-services/remote-access/uis-vpn/ubuntu1604#password-file
      secrets = ["/var/lib/ipsec.secrets"];

      connections."%default" = {
        keyexchange = "ikev2";
        ikelifetime = "60m";
        keylife = "20m";
        rekeymargin = "3m";
        keyingtries = "1";
      };

      connections.CAM = {
        left = "%any";
        leftid = "apj39+${config.networking.hostName}vpn@cam.ac.uk";
        leftauth = "eap";
        leftsourceip = "%config";
        leftfirewall = "yes";
        right = "vpn.uis.cam.ac.uk";
        rightid = "\"CN=vpn.uis.cam.ac.uk\"";
        # from https://help.uis.cam.ac.uk/service/network-services/remote-access/uis-vpn/ubuntu1604
        rightcert = "${./cambridge-vpn-2022.crt}";
        rightsubnet = "0.0.0.0/0";
        auto = "add";
      };

      # Setup instructions: https://www.cst.cam.ac.uk/local/sys/vpn2/linux
      # Password from https://vpnpassword.cl.cam.ac.uk/
      connections.CL = {
        reauth = "no";
        left = "%any";
        leftid = "apj39-${config.networking.hostName}";
        leftauth = "eap";
        leftsourceip = "%config4,%config6";
        leftfirewall = "yes";
        right = "vpn2.cl.cam.ac.uk";
        rightid = "%any";
        rightsendcert = "never";
        rightsubnet = "128.232.0.0/16,129.169.0.0/16,131.111.0.0/16,192.18.195.0/24,193.60.80.0/20,193.63.252.0/23,172.16.0.0/13,172.24.0.0/14,172.28.0.0/15,172.30.0.0/16,10.128.0.0/9,10.64.0.0/10,2001:630:210::/44,2a05:b400::/32";
        auto = "add";
      };

      ca.CL = {
        auto = "add";
        cacert = "${./cambridge-cl-vpn-2023.pem}";
      };
    };
  };
}
