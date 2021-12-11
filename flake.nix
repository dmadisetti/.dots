# Nixx
# git clone https://github.com/srid/nixos-config
{
  description = "dmadisetti meets NixOS";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official nix cache.
    nixpkgs.url = "github:nixos/nixpkgs/715f63411952c86c8f57ab9e3e3cb866a015b5f2";

    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
      };
      homeConfig = config: { ... }: {
         imports = [ config ];
      };
      mkComputer = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        # Arguments to pass to all modules.
        # config.system.build.toplevel = system;
        specialArgs = { inherit system inputs; };
        modules = (
          [
            # System configuration for this host
            configurationNix
            ./nix/common.nix

            # home-manager configuration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dylan = homeConfig ./nix/dylan.nix
                {
                  inherit inputs system pkgs;
                };
            }
          ] ++ extraModules
        );
      };
    in
    {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      #
      nixosConfigurations = {
        exalt = mkComputer
          ./nix/machines/exalt.nix
          [
            ./nix/sway.nix
          ];
      };
   };
}
