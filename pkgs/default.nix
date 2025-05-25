{
  self,
  pkgs,
  inputs,
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit self inputs; });
in
{
  yourstruly-sydney = pkgs.callPackage ./by-name/yo/yourstruly-sydney { };
  # nunito = pkgs.callPackage ./by-name/nu/nunito { };
  nistune = pkgs.callPackage ./by-name/ni/nistune { };
}
