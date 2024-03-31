{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  virtualHost = "freshrss.${domain}";
  url = "https://${virtualHost}";
in
{
  sops.secrets.freshrss = {
    owner = "${config.services.freshrss.user}";
  };

  services.freshrss = {
    enable = true;
    baseUrl = "${url}";
    passwordFile = config.sops.secrets.freshrss.path;
    virtualHost = "${virtualHost}";
  };

  services.nginx.virtualHosts."${config.services.freshrss.virtualHost}" = {
    useACMEHost = "${config.networking.domain}";
    forceSSL = true;
  };

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "${config.services.freshrss.dataDir}";
        user = "${config.services.freshrss.user}";
        group = "${config.services.freshrss.user}";
        mode = "u=rwx,g=rwx,o=";
      }
    ];
  };
}
