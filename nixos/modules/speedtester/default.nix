{ pkgs, lib, config, ... }:

{
  options = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf ;
}
