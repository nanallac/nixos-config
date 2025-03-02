{ lib
, mkWindowsAppNoCC
, wine
, wineArch
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:

mkWindowsAppNoCC rec {
  inherit wine wineArch;

  pname = "nistune-${wineArch}";
  version = "1.4.6";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];
  fileMapDuringAppInstall = true;

  src = {
    win32 = builtins.fetchurl {
      url = "https://www.nistune.com/releases/Nistune_1.4.6_setup.exe";
      sha256 = lib.fakeSha256;
    };
  }."${wineArch}";

  winAppInstall = ''
    $WINE start /unix ${src} /S
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Nistune/nistune.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Nistune";
      categories = [ "Other" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = builtins.fetchurl {
      url = "https://nistune.com/favicon.ico";
      sha256 = lib.fakeSha256;
    };
  };

  meta = with lib; {
    description = "Nistune is a real-time tuning suite designed especially for Nissans.";
    homepage = "https://www.nistune.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ nanallac ];
    platforms = [ "x86_64-linux" ];
  };

}
