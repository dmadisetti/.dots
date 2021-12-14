# Nixx
# git clone https://github.com/srid/nixos-config
{
  description = "dmadisetti meets NixOS";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official nix cache.
    nixpkgs.url = github:nixos/nixpkgs/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sensitive.url = "/home/dylan/.dotfiles/nix/sensitive";

  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, ... }:
    let
      system = "x86_64-linux";
      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
      };
      wms = { i3 = "x"; sway = "wayland"; fb = "none"; };
      homeConfig = config: userConfigs: wm: { ... }: {
        imports = [ config ] ++ userConfigs ++ (if wms ? "${wm}" then [
          ./nix/home/display.nix
          (./nix + "/home/${wm}.nix")
        ] else [ ]);
      };
      mkComputer = configurationNix: wm: extraModules: userConfigs: nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs sensitive; };
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
              home-manager.users.dylan = homeConfig ./nix/home/dylan.nix userConfigs wm
                {
                  inherit inputs system pkgs;
                };
            }
          ] ++ extraModules ++ (if wms ? "${wm}" then [
            (./nix + ("/display/" + wms."${wm}") + ".nix")
          ] else [ ])
        );
      };
    in
    {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      #
      nixosConfigurations = {
        exalt = mkComputer ./nix/machines/exalt.nix "" [ ] [ ];
      };
    };
}
