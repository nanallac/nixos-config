{ inputs, config, pkgs, lib, ... }:

{
  imports = [ ];

  # Nix
  nix = {
    # channels not required for flake only.
    channel.enable = false;
    # `nix run nixpkgs#...` and `<nixpkgs>` resolve to flake's nixpkgs.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # auto-optimized-store = true;
      trusted-users = [ "@wheel" ];
      warn-dirty = false;
      keep-outputs = true;
      keep-derivations = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  documentation.nixos.enable = false;

  # Baseline Packages
  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = [
      pkgs.screen
      pkgs.htop
      pkgs.tree
    ];
  };

  programs.zsh.enable = true;

  # Locale & Time
  time.timeZone = "Australia/Perth";

  i18n = {
    defaultLocale = "en_AU.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };

  console.keyMap = "us";


  # Users
  users.mutableUsers = false;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # josh@koala
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
    # josh@tapir
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPirHdE6aQYvm4OdGhguk/+xTXfXBHppPz+qIiQ3SrgP josh@tapir"
  ];

  # fail2ban
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    ignoreIP = [
      "127.0.0.0/8"
      "100.64.0.0/10"
      "192.168.0.0/16"
    ];
  };

  # Networking
  networking = {
    domain = "nanall.ac";
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    # mix of hosts inheriting this file - potentially split this in the future.
    useRoutingFeatures = "both";
  };

  # per NixOS Wiki https://wiki.nixos.org/wiki/Tailscale
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    checkReversePath = "loose";
  };

  # prevent networking manager from clobbering tailscale state
  networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.tailscale0.rp_filter" = 0;
    "net.ipv4.conf.all.rp_filter" = 0;
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
}
