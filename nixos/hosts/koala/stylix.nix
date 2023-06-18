{ pkgs, ... }:

{
  stylix = {
    image = ./wallpaper.jpg;

    polarity = "dark";

    fonts = {
      serif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      sansSerif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      monospace= {
        name = "Fira Code";
        # package = with pkgs; [
        #   (nerdfonts.override { fonts = [ "FiraCode" ]; })
        # ];
        package = pkgs.fira-code;
      };
      sizes = {
        applications = 11;
        desktop = 11;
      };
    };
  };
}
