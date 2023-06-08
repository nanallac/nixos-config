{ self, config, lib, pkgs, ...}:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ./hardware-configuration.nix
    ../common/services
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "linode";
      dnsPropagationCheck = true;
      credentialsFile = "/root/linode.ini";
    };
  };

  # services = {
  #   gitea = {
  #     enable = true;
  #     appName = "Josh's Gitea server.";
  #     domain = "git..nanall.ac";
  #     rootUrl = "https://git.nanall.ac";
  #   };

  #   nginx = {
  #     enable = true;
  #     virtualHosts = {
  #       "git.nanall.ac" = {
  #         forceSSL = true;
  #         useACMEHost = "nanall.ac";
  #         locations = {
  #           "/" = {
  #             proxyPass = "http://localhost";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

  # users.users.nginx.extraGroups = [ "acme" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "rhino";
    firewall.enable = true;
  };

  users.users.root.hashedPassword = "!";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
  ];

  system.stateVersion = "22.11";
}
