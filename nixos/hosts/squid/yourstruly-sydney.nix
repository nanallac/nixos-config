{ inputs, config, ... }:

let
  domain = "yourstruly.sydney";
  url = "${domain}";
in
{
  sops.secrets = {
    hurricane = {
      owner = "acme";
    };
    "plausible/admin_password" = {};
    "plausible/keybase" = {};
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."yourstruly.sydney" = {
      domain = "yourstruly.sydney";
      extraDomainNames = [
        "*.yourstruly.sydney"
      ];
      dnsProvider = "hurricane";
      credentialsFile = config.sops.secrets.hurricane.path;
    };
  };

  services.nginx.virtualHosts = {
    ${url} = {
      forceSSL = true;
      useACMEHost = "yourstruly.sydney";
      locations = {
        "/" = {
          root = inputs.yourstruly-sydney;
        };
      };
    };

    "metrics.${url}" = {
      forceSSL = true;
      useACMEHost = "yourstruly.sydney";
      locations = {
        "/" = {
          proxyPass = "http://${config.services.plausible.server.listenAddress}:${toString config.services.plausible.server.port}";
        };
      };
    };
  };

  # services.plausible = {
  #   enable = true;
  #   adminUser = {
  #     activate = true;
  #     email = "sydbross@gmail.com";
  #     passwordFile = config.sops.secrets."plausible/admin_password".path;
  #   };
  #   server = {
  #     baseUrl = "https://metrics.${url}/";
  #     secretKeybaseFile = config.sops.secrets."plausible/keybase".path;
  #     disableRegistration = "invite_only";
  #   };
  # };
}
