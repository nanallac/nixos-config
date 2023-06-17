{
  description = "My NixOS infra.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nanallac-nur = {
      url = "github:nanallac/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, stylix, deploy-rs, nanallac-nur, ... }@inputs: {
    nixosConfigurations = {
      "koala" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/koala/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.josh = import ./hosts/koala/home.nix;
          }
          # stylix.nixosModules.stylix
        ];
      };

      "squid" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/squid/configuration.nix
        ];
      };
      
      "panda" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/panda/configuration.nix
        ];
      };

      "rhino" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({
            nixpkgs.overlays = [
              (final: prev: {
                nanallac-nur = inputs.nanallac-nur.packages."${prev.system}";
              })
            ];
          })
        
          ./hosts/rhino/configuration.nix
        ];
      };
    };

    deploy = {
      sshUser = "root";
      user = "root";
      sshOpts = [ "-p" "22" ];

      autoRollback = false;
      magicRollback = false;

      nodes = {
        "squid" = {
          hostname = "175.45.180.229";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."squid";
          };
        };
        "panda" = {
          hostname = "192.168.1.244";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."panda";
          };
        };
        "rhino" = {
          hostname = "192.168.1.109";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."rhino";
          };
        };
      };
    };
  };
}
