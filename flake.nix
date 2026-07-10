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
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    customOverlay = final: prev: {
      # Upstream nixpkgs bug: click-threading's pytest phase collects
      # docs/conf.py, which imports pkg_resources — unavailable under
      # Python 3.14. Patch it in every Python package set (via
      # pythonPackagesExtensions) so both vdirsyncer and khal build.
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (pyfinal: pyprev: {
            click-threading = pyprev.click-threading.overridePythonAttrs (_: {
              doCheck = false;
            });
          })
        ];

      dell-h625cdw-ppd = prev.stdenv.mkDerivation {
        pname = "dell-h625cdw-ppd";
        version = "1.0";
        src = ./pkgs/dell-h625cdw;
        nativeBuildInputs = [prev.autoPatchelfHook];
        buildInputs = [prev.cups];
        installPhase = ''
          mkdir -p $out/lib/cups/filter/Dell-Color-MFP-H625cdw
          cp DellSecureFilter $out/lib/cups/filter/Dell-Color-MFP-H625cdw/

          mkdir -p $out/share/cups/model/Dell
          sed \
            -e "s|/usr/lib/cups/filter/Dell-Color-MFP-H625cdw/DellSecureFilter|$out/lib/cups/filter/Dell-Color-MFP-H625cdw/DellSecureFilter|" \
            -e "s|/usr/lib/cups/filter/Dell-Color-MFP-H625cdw|$out/lib/cups/filter/Dell-Color-MFP-H625cdw|" \
            Dell_Color_MFP_H625cdw.ppd > $out/share/cups/model/Dell/Dell_Color_MFP_H625cdw.ppd
        '';
      };
    };
    pkgs = import nixpkgs {
      localSystem = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [customOverlay inputs.rust-overlay.overlays.default];
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
        {nixpkgs.overlays = [customOverlay inputs.rust-overlay.overlays.default];}
        ./hosts/babysnacks/configuration.nix
      ];
    };

    nixosConfigurations.gaming = lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = "x86_64-linux";}
        {nixpkgs.overlays = [customOverlay inputs.rust-overlay.overlays.default];}
        ./hosts/gaming/configuration.nix
      ];
    };

    nixosConfigurations.minipc = lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = "x86_64-linux";}
        {nixpkgs.overlays = [customOverlay inputs.rust-overlay.overlays.default];}
        ./hosts/minipc/configuration.nix
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
          inputs.stylix.homeModules.stylix
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
