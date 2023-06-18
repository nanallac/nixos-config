{ pkgs, config, lib, outputs, ... }:

let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Callanan";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "networkmanager"
    ];
    hashedPassword = "$6$0KOODrlgZ8LGrmKe$.fS3JbK3ey4HCOQozYhhkT21YsxM/m80FUkuB47HsN7F1ILrgYNsIriLUd0/VXhRFdm9VE2WJ2eOUkV9g.ILf/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
    ];
  };
  programs = {
    git = {
      userEmail = "josh@callanan.contact";
      userName = "Josh Callanan";
    };
  };
}
