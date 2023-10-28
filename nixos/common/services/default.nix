{ lib, inputs, outputs, ... }:

{
  imports = [
    ./tailscale.nix
    ./fail2ban.nix
    # ./resolved.nix
  ];
}
