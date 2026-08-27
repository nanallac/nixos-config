{ pkgs, config, lib, inputs, outputs, home-manager, ... }:

{
  users.users.josh =
    let
      ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
    in {
      isNormalUser = true;
      description = "Josh Callanan";

      shell = pkgs.zsh;

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
    };

  home-manager.users.josh = {
    home.stateVersion = "26.11";
    home.packages = with pkgs; [
      git
      thunderbird
      inkscape
      waypipe
      scrcpy
      mpv
      ffmpeg
      orca-slicer
      freecad-wayland
      calibre
      moonlight-qt
      emacs
    ];

    home.file.".emacs.d" = {
      source = inputs.emacs-config;
      recursive = true;
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        e = "emacsclient -nw --alternate-editor=''";
      };
      initContent = ''
                  setopt autocd
      '';
    };

    programs.git = {
      enable = true;


      settings = {
        user = {
          name = "Josh Callanan";
          email = "josh@callanan.contact";
        };

        init.defaultBranch = "main";

        gpg.format = "openpgp";
        gpg.openpgp.program = lib.getExe pkgs.gnupg;

        url."https://github.com/".insteadOf = [ "gh:" "github:" ];
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
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

    programs.fzf = {
      enable = true;
    };

    services.emacs = {
      enable = true;
      package = pkgs.emacs;
      startWithUserSession = "graphical";
    };

    home.sessionVariables.EDITOR = "emacsclient -nw --alternate-editor=''";
  };

  nix.settings.trusted-users = [ "josh" ];
}
