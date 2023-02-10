{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  home.packages = with pkgs; [
    neovim
    htop
    bitwarden-cli
  ];

  programs.firefox = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Josh Callanan";
    userEmail = "joshua.callanan@pm.me";
    extraConfig = {
      init.defaultBranch = "main";
      url = {
        "https://github.com/".insteadOf = [ "gh:" "github:" ];
      };
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
