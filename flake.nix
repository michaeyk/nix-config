{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    yazi.url = "github:sxyazi/yazi";
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
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
          inherit inputs;
        };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          # sops-nix.nixosModules.sops
          # stylix.homeManagerModules.stylix
          ./users/mike/home.nix
        ];
      };
    };
  };
}
