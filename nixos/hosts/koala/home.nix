{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    iosevka
    gnomeExtensions.pop-shell
    gnomeExtensions.gsconnect
    evince
    tree
    htop
    bitwarden-cli
    bitwarden
    super-slicer-latest
    gnome.gnome-boxes
    thunderbird
    endeavour
    kanidm
    freecad
    calibre
    sops
    inkscape
    davinci-resolve
    ffmpeg
    freetube
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-gtk3;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
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

  programs.mpv = {
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
