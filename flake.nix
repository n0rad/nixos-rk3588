{
  description = "A minimal NixOS configuration for the RK3588/RK3588S based SBCs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixos-generators,
    ...
  }: let
    # Local system's architecture, the host you are running this flake on.
    localSystem = "x86_64-linux";
    pkgsLocal = import nixpkgs {system = localSystem;};
    # The native system of the target SBC.
    aarch64System = "aarch64-linux";
    pkgsNative = import nixpkgs {system = aarch64System;};
  in
    {
      nixosModules = {
        # Orange Pi 5 Plus SBC
        orangepi5plus = {
          core = import ./modules/boards/orangepi5plus.nix;
          sd-image = ./modules/sd-image/orangepi5plus.nix;
        };
      };

      nixosConfigurations =
        # UEFI system, boot via edk2-rk3588 - fully native
        (nixpkgs.lib.mapAttrs'
          (name: board:
            nixpkgs.lib.nameValuePair
            (name + "-uefi")
            (nixpkgs.lib.nixosSystem {
              system = aarch64System; # native or qemu-emulated
              specialArgs.rk3588 = {
                inherit nixpkgs;
                pkgsKernel = pkgsNative;
              };
              modules = [
                board.core
                ./modules/configuration.nix
                {
                  networking.hostName = name;
                }

                nixos-generators.nixosModules.all-formats
              ];
            }))
          self.nixosModules);
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = {
        # UEFI raw image
        rawEfiImage-opi5plus = self.nixosConfigurations.orangepi5plus-uefi.config.formats.raw-efi;
      };
    });
}
