{ ... }:

let
  username = "deploy";
in
{
  users.users."${username}" = {
    description = "System Deployment";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
    ];
  };

  nix.settings.trusted-users = [ username ];
  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}
