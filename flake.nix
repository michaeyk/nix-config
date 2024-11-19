{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    yazi.url = "github:sxyazi/yazi";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    stylix,
    sops-nix,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
       overlays = [
         inputs.hyprpanel.overlay

    #      (final: prev: {
    #            matugen = final.rustPlatform.buildRustPackage rec {
    #              pname = "matugen";
    #              version = "2.4.0";

    #              src = final.fetchFromGitHub {
    #                owner = "InioX";
    #                repo = "matugen";
    #                rev = "refs/tags/v${version}";
    #                hash = "sha256-l623fIVhVCU/ylbBmohAtQNbK0YrWlEny0sC/vBJ+dU=";
    #              };

    #              cargoHash = "sha256-FwQhhwlldDskDzmIOxhwRuUv8NxXCxd3ZmOwqcuWz64=";

    #              meta = {
    #                description = "Material you color generation tool";
    #                homepage = "https://github.com/InioX/matugen";
    #                changelog = "https://github.com/InioX/matugen/blob/${src.rev}/CHANGELOG.md";
    #                license = final.lib.licenses.gpl2Only;
    #                maintainers = with final.lib.maintainers; [ lampros ];
    #                mainProgram = "matugen";
    #              };
    #            };
    #          })      
           ];
  };
  in {
    # Please replace my-nixos with your hostname
    nixosConfigurations.babysnacks = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit pkgs inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
      ];
    };

    homeConfigurations = {
      mike = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          # sops-nix.nixosModules.sops
          stylix.homeManagerModules.stylix
          ./home.nix
        ];
      };
    };
  };
}
