{
  description = "My NixOS infra.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-config = {
      url = "github:nanallac/emacs.d?ref=main";
      flake = false;
    };

    nix-maid = {
      url = "github:viperML/nix-maid";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tic-tac-toe = {
      url = "github:nanallac/tic-tac-toe";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hearth = {
      url = "git+file:/home/josh/dev/hearth";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, nix-maid, deploy-rs, tic-tac-toe, hearth, ... }@inputs:
    {
      nixosConfigurations =
        let
          mkHost = { hostname, system, users ? [] }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs self system; };
              modules = [
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.home-manager.nixosModules.home-manager
                { home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  # for emacs config
                  home-manager.extraSpecialArgs = { inherit inputs; }; }
                ./modules/core
                ./hosts/${hostname}
                { networking.hostName = hostname; }
              ] ++ map (user: ./users/${user}) users;
            };
        in
          {
            "koala" = mkHost {
              hostname = "koala";
              system = "x86_64-linux";
              users = [ "josh" ];
            };

            "tapir" = mkHost {
              hostname = "tapir";
              system = "x86_64-linux";
              users = [ "josh" ];
            };

            "bison" = mkHost {
              hostname = "bison";
              system = "x86_64-linux";
              users = [ "josh" ];
            };

            "squid" = mkHost {
              hostname = "squid";
              system = "x86_64-linux";
            };

            "moose" = mkHost {
              hostname = "moose";
              system = "x86_64-linux";
            };

            "finch" = mkHost {
              hostname = "finch";
              system = "aarch64-linux";
            };
          };

      images = {
        "finch" = (self.nixosConfigurations."finch".extendModules {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            {
              disabledModules = [ "profiles/base.nix" ];
            }
          ];
        }).config.system.build.sdImage;
      };

      packages.x86_64-linux = import ./pkgs {
        inherit self inputs;
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };
    };
}
