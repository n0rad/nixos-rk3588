{
  description = "A minimal NixOS configuration for the RK3588/RK3588S based SBCs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
  }@inputs: {
      nixosConfigurations.orangepi5plus-uefi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./modules/boards/orangepi5plus.nix
          ./modules/configuration.nix
          {
            networking.hostName = "orangepi5plus";
          }

          nixos-generators.nixosModules.all-formats
        ];
      };
    };
}
