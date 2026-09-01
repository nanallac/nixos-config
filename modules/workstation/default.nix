{ pkgs, ... }:

{
  imports = [
    ./zen.nix
  ];

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Source Serif 4 Display" ];
        sansSerif = [ "Source Sans 3" ];
        monospace = [ "0xProto Nerd Font Mono" ];
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

  # Pretty boot process
  boot = {
    plymouth = let theme = "lone"; in {
      enable = true;
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
}
