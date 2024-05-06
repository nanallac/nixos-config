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

    yourstruly-sydney = {
      url = "github:sydbross/yourstruly.sydney";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs: {

    nixosConfigurations = {
      "koala" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/koala/configuration.nix
        ];
      };

      "squid" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/squid/configuration.nix
        ];
      };

      "moose" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/moose/configuration.nix
        ];
      };

      "panda" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/panda/configuration.nix
        ];
      };
    };

    deploy = {
      sshUser = "deploy";
      sshOpts = [ "-p" "22" ];
      user = "root";

      autoRollback = false;
      magicRollback = false;

      nodes = {
        "koala" = {
          hostname = "127.0.0.1";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."koala";
          };
        };

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

        "moose" = {
          hostname = "192.168.1.40";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."moose";
          };
        };
      };
    };
  };
}
