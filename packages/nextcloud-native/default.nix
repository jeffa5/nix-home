{pkgs}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "nextcloud-native";
  version = "1.0.12781";

  # https://nati.ve/ (Obiente's "nati.ve" client) only publishes nightly
  # builds, no stable releases. To bump: pick a newer tag/version from
  # https://github.com/Obiente/native/releases and update the hash.
  nightlyTag = "nightly-20261017-1716-run2429-9547466e";

  src = pkgs.fetchurl {
    url = "https://github.com/Obiente/native/releases/download/${finalAttrs.nightlyTag}/nextcloudnative_${finalAttrs.version}_amd64.deb";
    hash = "sha256-H5bU/Tsz8ljbdz84d4HQhyUPcrl3lLsw6ZKBgxJrhmA=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
    addDriverRunpath
  ];

  # the .deb ships a self-contained jpackage app-image: a jlinked JRE plus
  # a native launcher, not something to compile
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    alsa-lib
    fontconfig
    libGL
    libX11
    libxext
    libxi
    libxrender
    libxtst
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r opt/nextcloudnative $out/opt/nextcloudnative

    install -Dm444 opt/nextcloudnative/lib/NextcloudNative.png \
      $out/share/icons/hicolor/512x512/apps/nextcloud-native.png

    install -Dm444 opt/nextcloudnative/lib/nextcloudnative-NextcloudNative.desktop \
      $out/share/applications/nextcloud-native.desktop
    substituteInPlace $out/share/applications/nextcloud-native.desktop \
      --replace-fail "/opt/nextcloudnative/bin/NextcloudNative" "nextcloud-native" \
      --replace-fail "Icon=dev.obiente.nextcloudnative" "Icon=nextcloud-native"

    makeWrapper $out/opt/nextcloudnative/bin/NextcloudNative $out/bin/nextcloud-native \
      --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.libsecret pkgs.xdg-utils]}

    runHook postInstall
  '';

  # skiko (the Compose Multiplatform Skia binding) links libGL directly;
  # point it at the real driver instead of the buildInputs stub
  postFixup = ''
    addDriverRunpath $out/opt/nextcloudnative/lib/app/libskiko-linux-x64.so
  '';

  meta = {
    description = "Adaptive native Nextcloud client for desktop (nati.ve)";
    homepage = "https://nati.ve/";
    license = pkgs.lib.licenses.agpl3Plus;
    platforms = ["x86_64-linux"];
    mainProgram = "nextcloud-native";
    sourceProvenance = [pkgs.lib.sourceTypes.binaryNativeCode];
  };
})
