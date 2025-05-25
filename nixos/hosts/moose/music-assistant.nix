{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "music.${domain}";
in
{
  services.music-assistant = {
    enable = true;
    providers = [
      "chromecast"
      "deezer"
      "jellyfin"
      "radiobrowser"
      "slimproto"
      "snapcast"
      "spotify"
      "spotify_connect"
    ];
  };

  environment.systemPackages = [ pkgs.snapcast ];

  networking.firewall.allowedTCPPorts = [ 1780 3483 8095 8097 8098 9000 9090 ];
  networking.firewall.allowedUDPPorts = [ 3483 ];

  services.nginx.virtualHosts."${url}" = {
    useACMEHost = config.networking.domain;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:8095";
        proxyWebsockets = true;
      };
    };
  };

  # required for mdns discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.snapserver = {
    enable = true;
    openFirewall = true;
    streams.default = {
      type = "pipe";
      location = "/run/snapserver/pipewire";
    };
  };

  environment.persistence."/keep" = {
    directories = [
      {
        # no user or group here due to the service config
        directory = "/var/lib/music-assistant";
        mode = "0700";
      }
    ];
  };
}
