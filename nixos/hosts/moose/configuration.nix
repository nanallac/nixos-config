{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common
      #./kanidm.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "moose";
  networking.networkmanager.enable = true;
  networking.hostId = "fd82eaf9";

  # Keep the following directories
  # (https://grahamc.com/blog/erase-your-darlings/)
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
