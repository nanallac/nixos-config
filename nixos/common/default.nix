{ ... }:

{
  imports = [
    ./services
  ];

  boot.tmp.cleanOnBoot = true;

  networking.domain = "nanall.ac";

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  time.timeZone = "Australia/Perth";
}
