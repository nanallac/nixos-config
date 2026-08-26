{ config, pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
    settings = {
      sunshine_name = config.networking.hostName;
    };

    applications = {
      apps = [
        {
          name = "Steam Big Picture";
          detached = [
            "sudo -u josh ${pkgs.util-linux}/bin/setsid steam steam://open/bigpicture"
          ];
          prep-cmd = [
            {
              do = "";
              undo = ''
                sudo -u josh ${pkgs.util-linux}/bin/setsid steam steam://close/bigpicture
              '';
            }
          ];
          image-path = "steam.png";
        }
      ];
    };

  };

    environment.systemPackages = [
      pkgs.extest
      pkgs.gnomeExtensions.no-overview
    ];

    systemd.user.services.sunshine.environment = {
      LD_PRELOAD = "${pkgs.extest}/lib/libextest.so";
    };


  services.udev.extraRules = ''
  KERNEL=="uinput", MODE="0660", GROUP="uinput"
  KERNEL=="uhid",   MODE="0660", GROUP="uinput"
  '';

  users.users.josh.extraGroups = [ "uinput" "video" "render" "input" ];

  networking.firewall.allowedTCPPorts = [ 47990 47984 47989 ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "sunshine.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
        locations."/" = {
          proxyPass = "https://localhost:47990";
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
