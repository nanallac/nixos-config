{ lib, inputs, outputs, ... }:

{
  imports = [
    ./tailscale.nix
    ./fail2ban.nix
    ./nix.nix
  ];

  networking.domain = "nanall.ac";

  time.timeZone = "Australia/Perth";
}
