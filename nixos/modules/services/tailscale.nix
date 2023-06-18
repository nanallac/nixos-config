{ lib, config, ... }:

{
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}
