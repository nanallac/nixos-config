{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    # coerce ollama into using RX5700XT
    rocmOverrideGfx = "10.1.0";
    host = "0.0.0.0";
  };

  services.open-webui = {
    enable = true;
    environment =  {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_CONTEXT_LENGTH = "16384";
      OLLAMA_KEEP_ALIVE = "30m";
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
      "ollama.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.ollama.port}";
          proxyWebsockets = true;
        };
      };
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
      credentialFiles = {
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets.porkbun_secret_api_key_file.path;
        "PORKBUN_API_KEY_FILE" = config.sops.secrets.porkbun_api_key_file.path;
      };
    };
  };

  sops.secrets = {
    porkbun_secret_api_key_file = {
      owner = "acme";
    };
    porkbun_api_key_file = {
      owner = "acme";
    };
  };
}
