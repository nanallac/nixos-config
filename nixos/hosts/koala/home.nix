{ config, pkgs, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";

  home.shellAliases = {
    e = "emacsclient -nw";
  };

  fonts.fontconfig = {
    enable = true;
  };

  home.packages = with pkgs; [

    iosevka
    gnomeExtensions.pop-shell
    gnomeExtensions.caffeine
    evince
    tree
    htop
    bitwarden-cli
    bitwarden
    thunderbird
    kanidm
    freecad
    sops
    inkscape
    ffmpeg
    freetube
    remmina
    moonlight-qt
    # orca-slicer

    gnome-remote-desktop

    nixfmt-classic
    clojure-lsp
    nil
    nodePackages.bash-language-server
    shfmt
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
    autosuggestion.enable = true;
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
    userEmail = "josh@callanan.contact";
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
        "gsconnect@andyholmes.github.io"
        "caffeine@patapon.info"
      ];
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
