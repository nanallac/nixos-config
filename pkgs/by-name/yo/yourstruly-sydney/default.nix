{
  stdenvNoCC,
  fetchFromGitHub,
  minify,
}:

stdenvNoCC.mkDerivation {
  pname = "yourstruly-sydney";
  version = "v1.0";

  src = fetchFromGitHub {
    owner = "sydbross";
    repo = "yourstruly.sydney";
    rev = "v1.0";
    sha256 = "sha256-ymzWaeYlebkFTjQ09Hus+f/vbU7pykIQL6uw7wsiW7k=";
  };

  buildInputs = [ minify ];

  buildPhase = ''
    runHook preBuild
    echo "Minifying files..."
    minify        \
      --recursive \
      --all       \
      --sync      \
      --output .  \
      .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/srv/yourstruly.sydney
    cp -r * $out/srv/yourstruly.sydney
    runHook postInstall
  '';
}
