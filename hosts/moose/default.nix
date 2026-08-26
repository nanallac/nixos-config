{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./jellyfin.nix
    ./calibre-web.nix
    ./freshrss.nix
    ./vector.nix
    ./reverse-proxy.nix
    ./mqtt.nix
    ./nextcloud.nix
    ./music-assistant.nix
    ./tic-tac-toe.nix
    # ./forgejo.nix
    ./scrutiny.nix
    ./go2rtc.nix
    ./ntfy-sh.nix
    ./searx.nix
    ./ipcam-timelapse.nix
    ./ipcam.nix
    ./pinchflat.nix
    ./peertube-runner.nix
    ./arr.nix
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
      "/var/lib/fail2ban"
      "/var/lib/acme"
    ];
  };

  # Keep the following directories
  # (https://grahamc.com/blog/erase-your-darlings/)
  systemd.tmpfiles.rules = [
    # SSH
    "d /keep/ssh 0755 root root -"
  ];

  systemd.enableEmergencyMode = false;

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
  sops.secrets = {
    porkbun_secret_api_key_file = {
      owner = "acme";
    };
    porkbun_api_key_file = {
      owner = "acme";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" "*.media.nanall.ac"];
      dnsProvider = "porkbun";
      credentialFiles = {
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets.porkbun_secret_api_key_file.path;
        "PORKBUN_API_KEY_FILE" = config.sops.secrets.porkbun_api_key_file.path;
      };
    };
  };

  system.stateVersion = "23.05";
}
