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
      kdenlive-patched-dbus = prev.kdePackages.kdenlive.overrideAttrs (_old: rec {
        version = "26.03.70-dbus-fb0c86d";
        src = final.fetchFromGitHub {
          owner = "D-Ogi";
          repo = "kdenlive";
          rev = "fb0c86d4e6f6197a13e9b84aa45ef3da82a5f38a"; # feature/dbus-api-expansion
          hash = "sha256-hVU2UcxRCT/122a667sIHKwCxVqdMINBx8NbEmjr1qA=";
        };
        patches = (_old.patches or []) ++ [./pkgs/kdenlive-dbus/cxx20-quickjs-designators.patch];
        meta = (_old.meta or {}) // {
          description = "Kdenlive with D-Bus scripting API patch for mcp-kdenlive";
        };
      });

      kdenlive-mcp-dbus = let
        mcpKdenliveSrc = final.fetchFromGitHub {
          owner = "D-Ogi";
          repo = "mcp-kdenlive";
          rev = "afe585143f631fa00f62a1d22207d85df06a0d74";
          hash = "sha256-eB4ZUntB4ooLS1FXgRmEwW8wVLK1gxNQqJV9gss+IcE=";
        };
        kdenliveApiSrc = final.fetchFromGitHub {
          owner = "D-Ogi";
          repo = "kdenlive-api";
          rev = "d1f87baa127d2950d89b923f7a0206defb124073";
          hash = "sha256-7rXrBiD6RyZ6tXrqPWEALAvOszoamyiPfVjvfbTla4A=";
        };
        python = (final.python312.override {
          packageOverrides = pyFinal: pyPrev: {
            # Avoid rebuilding/checking a flaky transitive test dependency of
            # python312Packages.mcp on nixos-unstable.
            inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs (_: {
              doCheck = false;
            });
            fastapi = pyPrev.fastapi.overridePythonAttrs (_: {
              doCheck = false;
            });
            mcp = pyPrev.mcp.overridePythonAttrs (_: {
              doCheck = false;
            });
          };
        }).withPackages (ps:
          with ps; [
            mcp
            pydbus
            pygobject3
            dbus-next
          ]);
      in
        final.writeShellApplication {
          name = "kdenlive-mcp-dbus";
          runtimeInputs = [final.dbus];
          text = ''
            export PYTHONPATH="${mcpKdenliveSrc}:${kdenliveApiSrc}''${PYTHONPATH:+:$PYTHONPATH}"
            exec ${python}/bin/python -m mcp_kdenlive "$@"
          '';
        };

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
          ./home/programs/host-extras.nix
          ./home/programs/gaming.nix
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
          ./home/programs/host-extras.nix
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
