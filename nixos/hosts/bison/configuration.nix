{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd

    ./hardware-configuration.nix
    ./disk-config.nix
    ../../common
    ./sunshine.nix
    ./ai.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  systemd.user.services.steam = {
    enable = true;
    description = "Open steam in the background at boot";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent %U";

      Restart = "on-failure";
      RestartSec = "5s";
      Type = "simple";
      Environment = [ "DISPLAY=:0" ];
    };
  };


  networking = {
    hostName = "bison";
    domain = "nanall.ac";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # excludePackages = [ pkgs.xterm ];
    videoDrivers = [ "amdgpu" ];

    # Enable the GNOME Desktop Environment.
    displayManager.gdm = {
      enable = true;
      # wayland = true;
    };
    desktopManager.gnome.enable = true;
  };


  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];


  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      {
        lockAll = false;
        settings = {

          "org/gnome/desktop/wm/preferences" = {
            focus-new-windows = "smart";
          };

    "org/gnome/shell" = {
      enabled-extensions =
        [ "no-overview@fthx" ];
    };

          "org/gnome/shell/extensions/just-perfection" = {
            startup-status = lib.gvariant.mkInt32 0;
          };
        };
      }
    ];

  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-session
    lact
    wlr-protocols
    wayland-protocols

    gnomeExtensions.just-perfection

    gnomeExtensions.no-overview

  ];

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
        {
            return polkit.Result.NO;
        }
    });
  '';

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "josh";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";

}
