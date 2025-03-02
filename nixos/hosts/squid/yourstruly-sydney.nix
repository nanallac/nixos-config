{ inputs, config, self, ... }:

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
          root = "${self.packages.x86_64-linux.yourstruly-sydney}/srv/yourstruly.sydney/";
        };
      };
    };
  };
}
