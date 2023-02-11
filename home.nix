{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    neovim
    tree
    htop
    bitwarden-cli
  ];

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      hostname = {
        ssh_only = false;
	trim_at = "";
      };
    };
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
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
