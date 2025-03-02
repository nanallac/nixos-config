{ config, pkgs, ... }:

let
  user = "wyoming-satellite";
in
{
  environment.systemPackages = [
    pkgs.alsa-utils
    pkgs.pipewire
    pkgs.wyoming-satellite
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  services.wyoming = {
    satellite = {
      enable = true;
      user = user;
      group = user;
      name = config.networking.hostName;
      area = "Living Room";
      vad.enable = false;
      sounds.awake = builtins.fetchurl {
        url = "https://github.com/rhasspy/wyoming-satellite/raw/master/sounds/awake.wav";
        sha256 = "6b25dd2abaf7537865222ca9fd6e14fbf723458526fb79bbe29d8261d1320724";
      };
      sounds.done = builtins.fetchurl {
        url = "https://github.com/rhasspy/wyoming-satellite/raw/master/sounds/done.wav";
        sha256 = "bc5c914bfa860a77fa9d88ac2d96601adfede578cf146637ec98b5688911a951";
      };
      extraArgs = [
        "--debug"
        # "--wake-word-name=hey_jarvis"
        # "--wake-uri=tcp://192.168.1.186:10400"
      ];
    };
    # openwakeword = {
    #   enable = true;
    #   preloadModels = [
    #     "ok_nabu"
    #   ];
    #   extraArgs = [ "--debug" ];
    # };
  };

  networking.firewall.allowedTCPPorts = [ 10700 10400 ];

  users.users."${user}" = {
    isSystemUser = true;
    group = user;
    linger = true;
    extraGroups = [ "audio" ];
  };

  users.groups."${user}" = {};
}
