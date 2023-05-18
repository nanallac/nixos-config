{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc902" }:
let
  inherit (nixpkgs) pkgs;
  ghc = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps; [
    monad-par mtl
  ]);
in
  pkgs.stdenv.mkDerivation {
    name = "my-haskell-env-0";
    buildInputs = [ ghc ];
    shellHook = "eval $(egrep ^export ${ghc}/bin/ghc)";
  }
