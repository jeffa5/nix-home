{pkgs}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "4.29.0";

  # Anthropic's apt repo, https://downloads.claude.ai/claude-desktop/apt/stable
  # (see dists/stable/main/binary-amd64/Packages). To bump: pick the newest
  # Version/Filename/SHA256 from that index.
  src = pkgs.fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-SqD3Y9bAWseVAjkt1Q9df1xFWy8KQF1b3xVUrNg0Kok=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
    addDriverRunpath
  ];

  # an Electron app: the runtime libraries Chromium dlopens or links against
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    libcap_ng
    libseccomp
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
    nspr
    nss
    pango
    pipewire
    systemd
  ];

  runtimeDependencies = with pkgs; [
    libGL
    libayatana-appindicator
    libnotify
    libsecret
    systemd
    vulkan-loader
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/share
    cp -r usr/lib/claude-desktop $out/lib/claude-desktop
    cp -r usr/share/icons $out/share/icons
    install -Dm444 usr/share/applications/com.anthropic.Claude.desktop \
      $out/share/applications/com.anthropic.Claude.desktop
    install -Dm444 usr/lib/claude-desktop/resources/linux-mime/com.anthropic.Claude.xml \
      $out/share/mime/packages/com.anthropic.Claude.xml

    # the setuid sandbox helper can't work from the store; Chromium falls
    # back to user namespaces
    rm $out/lib/claude-desktop/chrome-sandbox

    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.xdg-utils pkgs.bubblewrap pkgs.socat pkgs.openssh]} \
      --set CLAUDE_CODE_LOCAL_BINARY ${pkgs.lib.getExe pkgs.claude-code} \
      --add-flags "--ozone-platform-hint=auto"

    runHook postInstall
  '';

  postFixup = ''
    addDriverRunpath $out/lib/claude-desktop/claude-desktop
  '';

  meta = {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai";
    license = pkgs.lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "claude-desktop";
    sourceProvenance = [pkgs.lib.sourceTypes.binaryNativeCode];
  };
})
