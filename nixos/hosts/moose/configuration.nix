{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Media shares for Jellyfin - temporary, reassess once NAS migrated to be local.
  fileSystems."/mnt/media" = {
    device = "192.168.1.100:/mnt/storage0/media";
    fsType = "nfs";
    options = [
      "auto"
      "noatime"
      "x-systemd.automount"
    ];
  };

  networking = {
    hostName = "moose";
    networkmanager.enable = true;
    hostId = "fd82eaf9";
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # Keep the following directories
  # (https://grahamc.com/blog/erase-your-darlings/)
  systemd.tmpfiles.rules = [
    # SSH
    "d /keep/ssh 0755 root root -"

    # fail2ban
    "d /keep/var/lib/fail2ban 0750 root root -"
    "L /var/lib/fail2ban - - - - /keep/var/lib/fail2ban"

    # ACME certificates
    "d /keep/var/lib/acme 0750 acme acme -"
    "L /var/lib/acme - - - - /keep/var/lib/acme"

    # Jellyfin
    "d /keep/var/lib/jellyfin 0700 jellyfin jellyfin -"
    "L /var/lib/jellyfin - - - - /keep/var/lib/jellyfin"
  ];

  # Jellyfin
  services.jellyfin.enable   = true;
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  # NGINX
  services.nginx = {
    enable = true;
    recommendedTlsSettings   = true;
    recommendedProxySettings = true;
    recommendedGzipSettings  = true;
    recommendedOptimisation  = true;
    virtualHosts = {
      "_" = {
        default = true;
        rejectSSL = true;
        extraConfig = "return 444;";
      };
      "media.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
        locations = {
          "/" = {
            proxyPass = "http://localhost:8096";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  # Write the host keys to the keep
  services.openssh = {
    hostKeys = [
      {
        path = "/keep/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/keep/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # ACME certificates
  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "porkbun";
      credentialsFile = "/var/lib/acme/porkbun";
    };
  };

  system.stateVersion = "23.05";
}
