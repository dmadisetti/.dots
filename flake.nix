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
# A fair bit of inspiration from github:srid/nixos-config

{
  description = "dmadisetti meets NixOS";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official nix cache.
    nixpkgs.url = github:nixos/nixpkgs/1882c6b7368fd284ad01b0a5b5601ef136321292;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Wait for internal submodules
    # see: NixOS/nix/issues/5497
    # Cache invalidation is hard. Just increment/decrement around
    sensitive.url = "/home/dylan/.dots/nix/sensitive?cache-bust=2";

    # Common Grub2 themes
    grub2-themes.url = github:AnotherGroupChat/grub2-themes/nixos;
  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, ... }:
    let
      system = "x86_64-linux";

      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix { sensitive = sensitive; };
        config.allowUnfree = false;
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
        , isContainer ? false
        }: nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          # Arguments to pass to all modules.
          specialArgs = { inherit system inputs sensitive user self isContainer; };
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
            ] ++ extraModules ++ (if !isContainer then [
              ./nix/common/fonts.nix
              ./nix/common/getty.nix
              ./nix/common/head.nix
            ] else [ ]) ++
            (if wms ? "${wm}" then [
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
          isContainer = true;
        };
        momento = mkComputer {
          machineConfig = ./nix/machines/momento.nix;
          wm = sensitive.lib.default_wm;
          userConfigs = [ ./nix/home/live.nix ];
        };
      };

      # Technically not allowed, but whatever.
      live = self.nixosConfigurations.momento.config.system.build.isoImage;
      # TODO! Bootstrap script
      # bootstrap = ./nix/bootstrap/default.nix;
    };
}
