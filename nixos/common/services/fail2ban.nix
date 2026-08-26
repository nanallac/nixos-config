{ pkgs, ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "10m";
    ignoreIP = [
      "127.0.0.0/8"
      "100.64.0.0/16"
      "192.168.0.0/16"
    ];
  };
}
