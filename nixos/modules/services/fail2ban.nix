{ pkgs, ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.64.0.0/16"
      "192.168.0.0/16"
    ];
  };
}