{ config, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    # coerce ollama into using RX5700XT
    rocmOverrideGfx = "10.1.0";
  };

  services.open-webui = {
    enable = true;
    environment =  {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
    openFirewall = true;
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "chat.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
        locations."/" = {
          proxyPass = "http://localhost:8080";
          proxyWebsockets = true;
        };
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "porkbun";
      credentialsFile = config.sops.secrets.porkbun.path;
    };
  };

  sops.secrets.porkbun = {
    owner = "acme";
  };
}
