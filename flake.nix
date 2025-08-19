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
    yazi.url = "github:sxyazi/yazi";
    nur.url = "github:nix-community/NUR";
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    nurPkgs = import inputs.nur {
      inherit pkgs;
      nurpkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
    # Please replace my-nixos with your hostname
    nixosConfigurations.babysnacks = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./hosts/babysnacks/configuration.nix
      ];
    };

    nixosConfigurations.gaming = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
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
