#           ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖
#           ▜███▙       ▜███▙  ▟███▛
#            ▜███▙       ▜███▙▟███▛
#             ▜███▙       ▜██████▛
#      ▟█████████████████▙ ▜████▛     ▟▙
#     ▟███████████████████▙ ▜███▙    ▟██▙
#            ▄▄▄▄▖           ▜███▙  ▟███▛
#           ▟███▛             ▜██▛ ▟███▛
#          ▟███▛               ▜▛ ▟███▛
# ▟███████████▛                  ▟██████████▙
# ▜██████████▛                  ▟███████████▛
#       ▟███▛ ▟▙               ▟███▛
#      ▟███▛ ▟██▙             ▟███▛
#     ▟███▛  ▜███▙           ▝▀▀▀▀
#     ▜██▛    ▜███▙ ▜██████████████████▛
#      ▜▛     ▟████▙ ▜████████████████▛
#            ▟██████▙       ▜███▙
#           ▟███▛▜███▙       ▜███▙
#          ▟███▛  ▜███▙       ▜███▙
#          ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘
#
# Implemented machines:
#   • mamba - Dualboot Thinkpad daily driver
#   • slug  - WSL on the daily driver.
#   • exalt - Craptop converted for Nix hacking
#
# Implemented devices
#   • momento - Live USB stick with configs for amnesiac + installs
#
# A fair bit of inspiraton from github:srid/nixos-config

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

    # TODO: Wait for internal submodules
    # see: NixOS/nix/issues/5497
    # Cache invalidation is hard. Just increment/decrement around
    sensitive.url = "/home/dylan/.dots/nix/sensitive?cache-bust=9";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, ... }:
    let
      system = "x86_64-linux";
      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix;
        config.allowUnfree = true;
      };
      wms = { i3 = "x"; sway = "wayland"; fb = "none"; xmonad = "x"; };
      homeConfig = user: userConfigs: wm: { ... }: {
        imports = [ (./nix/home + "/${user}.nix") ]
          ++ userConfigs
          ++ (if wms ? "${wm}" then [
          ./nix/home/display.nix
          (./nix/home + "/${wm}.nix")
        ] else [ ]);
      };
      mkComputer =
        { machineConfig
        , user ? sensitive.lib.user
        , wm ? ""
        , extraModules ? [ ]
        , userConfigs ? [ ]
        }: nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          # Arguments to pass to all modules.
          specialArgs = { inherit system inputs sensitive user self; };
          modules = (
            [
              # System configuration for this host
              machineConfig
              ./nix/common.nix

              # home-manager configuration
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users."${user}" = homeConfig user userConfigs wm
                  {
                    inherit inputs system pkgs self;
                  };
              }
            ] ++ extraModules ++ (if wms ? "${wm}" then [
              ./nix/common/fonts.nix
              ./nix/common/getty.nix
              ./nix/common/head.nix
              (./nix + ("/display/" + wms."${wm}") + ".nix")
            ] else [ ])
          );
        };
    in
    {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      #
      nixosConfigurations = {
        mamba = mkComputer {
          machineConfig = ./nix/machines/mamba.nix;
          wm = "xmonad";
          userConfigs = [ ./nix/home/daily-driver.nix ];
        };
        exalt = mkComputer {
          machineConfig = ./nix/machines/exalt.nix;
          wm = "xmonad";
        };
        slug = mkComputer {
          machineConfig = ./nix/machines/slug.nix;
        };
        momento = mkComputer {
          machineConfig = ./nix/machines/momento.nix;
          wm = sensitive.lib.default_wm;
          userConfigs = [ ./nix/home/live.nix ];
        };
      };
      live = self.nixosConfigurations.momento.config.system.build.isoImage;
      # TODO! Bootstrap script
      # bootstrap = ./nix/bootstrap/default.nix;
    };
}
