{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    gnomeExtensions.pop-shell
    evince
    tree
    htop
    bitwarden-cli
    super-slicer-latest
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

  programs.helix = {
    enable = true;
    settings = {
      theme = "bogster";
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

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extension = false;

      disabled-extentions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
      ];

      enabled-extensions = [
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "pop-shell@system76.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
