{ lib, config, ... }:

{
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # See if this helps prevent nixos-rebuild failures.
  systemd.services.tailscaled.after = [ "NetworkManager-wait-online.service" ];
}
