{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    ../../common
    ./jellyfin.nix
    ./calibre-web.nix
    ./freshrss.nix
    ./vector.nix
    ./reverse-proxy.nix
    ./mqtt.nix
    ./nextcloud.nix
    # ./frigate.nix
    # ./forgejo.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "moose";
    networkmanager.enable = true;
    hostId = "fd82eaf9";
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  environment.persistence."/keep" = {
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      "/var/lib/postgresql"
    ];
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
  ];

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
  # Secrets
  sops.secrets.porkbun = {
    owner = "acme";
  };

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

  system.stateVersion = "23.05";
}
