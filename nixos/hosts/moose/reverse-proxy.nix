{ ... }:

let
  domain = "nanall.ac";
in
{
  services.nginx.virtualHosts = {
    "nas.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://192.168.1.100";
        proxyWebsockets = true;
      };
    };
    "ha.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://192.168.1.186:8123";
        proxyWebsockets = true;
      };
    };
    "akita.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "https://192.168.1.110:8006";
      };
    };
    "otter.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "https://192.168.1.120:8006";
      };
    };
    "3d.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://192.168.1.61";
      };
    };
    "sprinklers.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://192.168.30.202";
      };
    };
  };
}
