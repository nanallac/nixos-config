{ config, ... }:

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
    settings = {
      sunshine_name = config.networking.hostName;
    };
  };

  networking.firewall.allowedTCPPorts = [ 47990 ];
}
