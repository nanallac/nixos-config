{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/services
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "moose";
  networking.networkmanager.enable = true;
  networking.hostId = "fd82eaf9";

  # Keep the following directories (https://grahamc.com/blog/erase-your-darlings/)
  systemd.tmpfiles.rules = [
    # SSH
    "d /keep/ssh 0755 root root -"

    # fail2ban
    "d /keep/var/lib/fail2ban 0750 root root -"
    "L /var/lib/fail2ban - - - - /keep/var/lib/fail2ban"

    # ACME certificates
    "d /keep/var/lib/acme 0750 root root -"
    "L /var/lib/acme - - - - /keep/var/lib/acme"
  ];

  # Enable the OpenSSH daemon and keep keys.  
  services.openssh = {
    enable = true;
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
  
  # Add my SSH key to allow access 
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
  ];

  system.stateVersion = "23.05";
}

