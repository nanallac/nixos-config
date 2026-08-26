{ config, ... }:

{
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ config.sops.templates."nm-zebra.env".path ];
      profiles.Zebra = {
        connection = {
          id = "Zebra";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "Zebra";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };


  sops.secrets."wifi/zebra/psk" = {};
  sops.templates."nm-zebra.env" = {
    content = "PSK=${config.sops.placeholder."wifi/zebra/psk"}";
  };
}
