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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "moose";
  networking.networkmanager.enable = true;
  networking.hostId = "fd82eaf9";

  # Keep the following (https://grahamc.com/blog/erase-your-darlings/)
  systemd.tmpfiles.rules = [
    # SSH
    "d /keep/ssh 0755 root root -"
    "d /keep/var/lib/fail2ban 0750 root root -"

    # fail2ban
    "L /var/lib/fail2ban - - - - /keep/var/lib/fail2ban"
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
  
  # Add my SSH key to allow access 
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
  ];

  system.stateVersion = "23.05";
}

