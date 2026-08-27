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

}
