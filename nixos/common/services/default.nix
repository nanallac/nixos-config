{ lib, inputs, outputs, ... }:

{
  imports = [
    ./tailscale.nix
    ./fail2ban.nix
    ./sops.nix
    # ./resolved.nix
  ];

  services.openssh.enable = true;
}
