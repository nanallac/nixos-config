{ pkgs, config, lib, inputs, outputs, home-manager, ... }:

let ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    inputs.nix-maid.nixosModules.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "librewolf-151.0.2-1"
    "librewolf-unwrapped-151.0.2-1"
  ];


  users.mutableUsers = false;
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Callanan";

    extraGroups = [
      "wheel"
    ] ++ ifGroupExists [
      "networkmanager"
      "docker"
      "audio"
      "video"
      "disk"
      "input"
      "render"
      "dialout"
    ];
    hashedPassword = "$6$0KOODrlgZ8LGrmKe$.fS3JbK3ey4HCOQozYhhkT21YsxM/m80FUkuB47HsN7F1ILrgYNsIriLUd0/VXhRFdm9VE2WJ2eOUkV9g.ILf/";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
    ];


    # nix-maid:
    # https://viperml.github.io/nix-maid/api.html
    maid = {
      packages = builtins.attrValues {
        inherit (pkgs)
          tree
          htop
          git
          screen
          pandoc
          discount
        ;
      } ++ (if config.services.xserver.enable then builtins.attrValues {
        inherit (pkgs)
          thunderbird
          inkscape
          librewolf

          waypipe
          pavucontrol
          scrcpy
          mpv
          ffmpeg

          orca-slicer
          openscad
          freecad-wayland

          xwayland-satellite

          # bottles

          evince
          calibre

          bitwarden-cli
          kanidm_1_10
          sops

          sway
          wmenu
          rofi

          bibata-cursors

          # rustdesk

          moonlight-qt
        ;
      } else []);

      file.xdg_config."git/config".source = ./config/git/config;
      file.xdg_config."niri/config.kdl".source = ./config/niri/config.kdl;
    };
  };

  services.guix.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      e = "emacsclient -nw --alternate-editor=''";
    };

    interactiveShellInit = ''
      # autocd equivalent
      setopt autocd

      # direnv hook
      eval "$(direnv hook zsh)"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      hostname = {
        ssh_only = false;
        trim_at = "";
      };
    };
  };

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  nix.settings.trusted-users = [ "josh" ];

  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    defaultEditor = true;
    startWithGraphical = true;
  };

  # Font configuration
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Source Serif 4 Display"];
        sansSerif = ["Source Sans 3"];
        monospace = ["0xProto Nerd Font Mono"];
      };
    };

    fontDir.enable = true;

    enableDefaultPackages = true;
    packages = [
      pkgs.nerd-fonts._0xproto
      pkgs.fira-code
      pkgs.fira-code-symbols
      pkgs.font-awesome
      pkgs.source-sans
      pkgs.source-serif
    ];
  };



  # FZF
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };
}
