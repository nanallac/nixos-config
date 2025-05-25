{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
    ../../common
    # ./wyoming.satellite.nix
  ];

  services.squeezelite = {
    enable = true;
    # discovery was not occuring automagically
    # force usb speaker output
    extraArguments = ''
      -s 192.168.1.40 \
      -o "sysdefault:CARD=Phone"
    '';
  };


  services.actkbd.enable = true;
  services.actkbd.bindings = [
    # Mute
    { keys = [ 113 ]; events = [ "key" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
    }
    # Volume down
    { keys = [ 114 ]; events = [ "key" "rep" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1- unmute";
    }
    # Volume up
    { keys = [ 115 ]; events = [ "key" "rep" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1+ unmute";
    }
    # Mic Mute
    { keys = [ 190 ]; events = [ "key" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
    }
  ];


  # Keep this to make sure wifi works
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  environment.systemPackages = [
    pkgs.neofetch
    pkgs.htop
    pkgs.alsa-utils
    pkgs.usbutils
    pkgs.evtest
  ];

  system.stateVersion = "24.11";

  networking = {
    hostName = "finch";
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        Zebra.psk = "2304091040";
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
    extraModprobeConfig = '' options brcmfmac roamoff=1 feature_disable=0x82000 '';
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "snd-usb-audio" "usb_storage"];

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # hardware.alsa.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
