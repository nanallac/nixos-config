{ inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
      # inputs.dms-plugin-registry.nixosModules.default
    ];

  # Display Manager & Desktop Manager

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.plasma-login-manager.enable = true;
  };

  programs.kdeconnect.enable = true;

  # services.udisks2.enable = true;

  # programs.niri.enable = config.services.xserver.enable;

  # services.displayManager.dms-greeter = {
  #   enable = config.services.xserver.enable;
  #   compositor.name = "niri";
  #   package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  #   quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
  #   configHome = "/home/josh";
  # };

  # programs.dms-shell = {
  #   enable = config.services.xserver.enable;

  #   package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  #   quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

  #   plugins = {
  #     dankBatteryAlerts.enable = true;
  #     # USBManager = {
  #     #   enable = true;
  #     #   src = inputs.dms-plugin-registry.packages.${pkgs.system}.USBManager;
  #     # };
  #   };

  #   systemd = {
  #     enable = true;             # Systemd service for auto-start
  #     restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
  #   };

  #   # Core features
  #   enableSystemMonitoring = true;     # System monitoring widgets (dgop)
  #   enableVPN = true;                  # VPN management widget
  #   enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
  #   enableAudioWavelength = true;      # Audio visualizer (cava)
  #   enableCalendarEvents = true;       # Calendar integration (khal)
  # };

  environment.systemPackages =
    (if config.services.xserver.enable then builtins.attrValues {
      inherit (pkgs)
        alacritty
        fuzzel
        screen
        seahorse
      ;
    } else []);


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    plymouth =
      let theme = "lone"; in {
            # We only care about how the boot process looks on graphical systems
            enable = config.services.xserver.enable;
            theme = theme;
            themePackages = [
              # By default we would install all themes
              (pkgs.adi1090x-plymouth-themes.override {
                selected_themes = [ theme ];
              })
            ];
          };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    tmp.cleanOnBoot = true;
  };

  networking.hostName = "koala"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  services.xserver.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
	    General = {
		    Experimental = true;
	    };
    };
  };

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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
