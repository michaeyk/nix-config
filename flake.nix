{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    yazi.url = "github:sxyazi/yazi";
    nur.url = "github:nix-community/NUR";
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      localSystem = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          pyprland = prev.pyprland.overridePythonAttrs (old: rec {
            version = "2.6.1";
            src = prev.fetchPypi {
              pname = "pyprland";
              inherit version;
              hash = "sha256-9QsC3Kq4QShkWuZDchRe+/8LfembBedgnPMpirviKNM=";
            };
          });
        })
      ];
    };
    nurPkgs = import inputs.nur {
      inherit pkgs;
      nurpkgs = pkgs;
    };
  in {
    # Please replace my-nixos with your hostname
    nixosConfigurations.babysnacks = lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = "x86_64-linux";}
        ./hosts/babysnacks/configuration.nix
      ];
    };

    nixosConfigurations.gaming = lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = "x86_64-linux";}
        ./hosts/gaming/configuration.nix
      ];
    };

    homeConfigurations = {
      mike = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs nurPkgs;
          hostname = "unknown"; # Default hostname
        };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          # sops-nix.nixosModules.sops
          inputs.stylix.homeModules.stylix
          ./users/mike/home.nix
        ];
      };

      mike-gaming = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs nurPkgs;
          hostname = "gaming";
        };
        modules = [
          inputs.stylix.homeModules.stylix
          ./users/mike/home.nix
        ];
      };

      mike-babysnacks = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs nurPkgs;
          hostname = "babysnacks";
        };
        modules = [
          inputs.stylix.homeModules.stylix
          ./users/mike/home.nix
        ];
      };

      mike-remote = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs nurPkgs;
        };
        modules = [
          ./users/mike_remote/home.nix
        ];
      };

      ubuntu = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs nurPkgs;
        };
        modules = [
          inputs.stylix.homeModules.stylix
          ./users/ubuntu/home.nix
        ];
      };
    };
  };
}
