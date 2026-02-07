{pkgs, config, ...}: {
  environment.systemPackages = [pkgs.ollama];
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = ["llama3.2:3b" "deepseek-r1:1.5b"];
  };

  services.open-webui.enable = true;

  services.nginx.virtualHosts."OpenWebUI" = let
    authelia-snippets = import ../modules/authelia-snippets.nix {inherit pkgs;};
  in {
    serverName = "llm.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.open-webui.port}";
      proxyWebsockets = true;
      extraConfig = ''
        include ${authelia-snippets.proxy};
        include ${authelia-snippets.authelia-authrequest};
      '';
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
    extraConfig = ''
      include ${authelia-snippets.authelia-location};
    '';
  };
}
