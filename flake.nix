{
  description = "My NixOS infra.";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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

    tic-tac-toe = {
      url = "github:nanallac/tic-tac-toe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, tic-tac-toe, ... }@inputs: {

    packages.x86_64-linux = import ./pkgs {
      inherit self inputs;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

    # nixosModules.x86_64-linux = import ./nixos/modules {
    #   inherit self inputs;
    #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
    # };

    nixosConfigurations = {
      "koala" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/koala/configuration.nix
          # ./nixos/modules
        ];
      };

      "bison" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/bison/configuration.nix
        ];
      };

      "squid" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
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

      # "panda" = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   specialArgs = { inherit inputs; };
      #   modules = [
      #     ./nixos/hosts/panda/configuration.nix
      #   ];
      # };

      # "skunk" = nixpkgs.lib.nixosSystem {
      #   system = "aarch64-linux";
      #   specialArgs = { inherit inputs; };
      #   modules = [
      #     ./nixos/hosts/skunk/configuration.nix
      #   ];
      # };

      "finch" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/finch/configuration.nix
        ];
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

        "bison" = {
          hostname = "192.168.1.233";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."bison";
          };
        };

        "squid" = {
          hostname = "175.45.180.229";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."squid";
          };
        };

        # "panda" = {
        #   hostname = "192.168.1.244";
        #   profiles.system = {
        #     path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."panda";
        #   };
        # };

        "moose" = {
          hostname = "192.168.1.40";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."moose";
          };
        };

        "finch" = {
          hostname = "192.168.1.171";
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations."finch";
          };
        };
      };
    };
  };
}
