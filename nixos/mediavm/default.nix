{pkgs, ...}: let
  jitsiDomain = "meet.jit.si"; # swap to self-hosted later
  jitsiRoom = "2f0902b9-616f-4384-b403-64cbff7f8697";
  displayName = "jsj";
  launcherPage = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Home</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          background: #1a1a2e;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          font-family: sans-serif;
        }
        #launcher {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          width: 100vw;
        }
        button {
          background: #2d8a4e;
          color: white;
          border: none;
          cursor: pointer;
          font-size: 4rem;
          font-weight: bold;
          padding: 2rem 5rem;
          border-radius: 1rem;
        }
        button:hover { background: #236e3e; }
        #jitsi-container {
          display: none;
          position: fixed;
          top: 0; left: 0;
          width: 100vw;
          height: 100vh;
        }
      </style>
    </head>
    <body>
      <div id="launcher">
        <button onclick="startCall()">📞 Call Andrew</button>
      </div>
      <div id="jitsi-container"></div>
      <script src="https://${jitsiDomain}/external_api.js"></script>
      <script>
        function startCall() {
          document.getElementById('launcher').style.display = 'none';
          document.getElementById('jitsi-container').style.display = 'block';

          const api = new JitsiMeetExternalAPI('${jitsiDomain}', {
            roomName: '${jitsiRoom}',
            parentNode: document.getElementById('jitsi-container'),
            width: '100%',
            height: '100%',
            userInfo: { displayName: '${displayName}' },
            configOverwrite: {
              prejoinPageEnabled: false,
              prejoinConfig: { enabled: false },
              startWithVideoMuted: false,
              startWithAudioMuted: false,
              disableDeepLinking: true,
            },
          });

          function endCall() {
            api.dispose();
            document.getElementById('jitsi-container').style.display = 'none';
            document.getElementById('launcher').style.display = 'flex';
          }

          api.addEventListener('readyToClose', endCall);
          api.addEventListener('videoConferenceLeft', () => setTimeout(endCall, 2000));
        }
      </script>
    </body>
    </html>
  '';
in {
  imports = [../modules/openssh.nix];

  networking.hostName = "mediavm";
  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  services.nginx = {
    enable = true;
    virtualHosts.localhost.root = "${launcherPage}";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.cage}/bin/cage -- ${pkgs.firefox}/bin/firefox --kiosk http://localhost";
      user = "media";
    };
  };

  services.seatd.enable = true;

  users.users.media = {
    isNormalUser = true;
    extraGroups = ["audio" "video" "seat"];
  };

  environment.etc."firefox/policies/policies.json".text = builtins.toJSON {
    policies.Preferences = {
      "spatial.enabled" = {Value = true; Status = "locked";};
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # VM-specific overrides
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = true;
      memorySize = 2048;
      cores = 2;
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
  };
}
