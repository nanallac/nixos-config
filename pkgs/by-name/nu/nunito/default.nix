{
  stdenvNoCC,
  fetchzip,
  # fetchFromGitHub,
  # fontconfig,
  # python312,
  # python312Packages,
}:

stdenvNoCC.mkDerivation {
  name = "nunito";

  src = fetchzip {
    url = "";
    hash = "";
  };



  # src = fetchFromGitHub {
  #   owner = "googlefonts";
  #   repo = "nunito";
  #   rev = "43d16f963c5c341c10efa0bfe7a82aa1bea8a938";
  #   sha256 = "sha256-yZ+pPLcgyWRa8i3cn1SwJUskBzUl1na2mndhok1mMok=";
  # };

  # buildInputs =
  # # let
  # #   gftools = python312Packages.gftools.overrideAttrs (oldAttrs: rec { version = "0.8.8"; src = oldAttrs.src // { rev = "refs/tags/v${version}"; hash = ""; }; });
  # # in
  #   [ fontconfig python312 python312Packages.gftools python312Packages.fontbakery ];

  # # env var is a workaround so we don't have to downgrade python packages

  # buildPhase = ''
  #   runHook preBuild
  #   echo "Executing ./sources/build.sh..."
  #   export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
  #   cd ./sources
  #   sed -i "s/--axis-order 'wght' 'ital' //" ./build.sh
  #   ./build.sh
  #   cd ..
  #   runHook postBuild
  # '';

  # #     install -Dm644 -t $out/share/fonts/truetype fonts/variable/*.ttf
  # installPhase = ''
  #   runHook preInstall
  #   mkdir $out
  #   cp -r * $out/
  #   runHook postInstall
  # '';
}
