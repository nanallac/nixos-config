{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  home.packages = with pkgs; [
    firefox
    neovim
    htop
  ];

  programs.git = {
    enable = true;
    userName = "Josh Callanan";
    userEmail = "joshua.callanan@pm.me";
  };

  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
}
