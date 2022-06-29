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
# » Implemented devices:
#    • momento → Live USB stick with configs for amnesiac + installs
#
# » Implemented machines:
#    • brick → Tower that works as router, 610 NVidia graphics lol
#    • exalt → Craptop converted for Nix hacking
#    • lambda → Main workstation with nvidia drivers and plex
#    • mamba → Dualboot Thinkpad daily driver
#    • wsl → WSL on the daily driver.
#
# A fair bit of inspiration from github:srid/nixos-config
{
  description = "⚫⚫⚫s on NixOS";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official nix cache.
    # nixpkgs.url = "/home/dylan/src/nixpkgs-local?cache-bust=4";
    # TODO: Change to patch system NixOs/nix/issues#3920
    nixpkgs.url = github:nixos/nixpkgs/f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Build our own wsl
    nixos-wsl.url = github:nix-community/NixOS-WSL;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Wait for internal submodules
    # see: NixOS/nix/issues/5497
    # Cache invalidation is hard. Just increment/decrement around
    # or run the fish command `unlock`, which will scrub flake.lock
    sensitive.url = "path:./nix/spoof";
    sensitive.inputs.nixpkgs.follows = "nixpkgs";

    # dots manager
    dots-manager.url = "path:./dots-manager";
    dots-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Common Grub2 themes
    grub2-themes.url = github:vinceliuice/grub2-themes;
    grub2-themes.inputs.nixpkgs.follows = "nixpkgs";
    grub2-themes-png.url = github:AnotherGroupChat/grub2-themes-png;
    grub2-themes-png.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: Fix grub2-themes so that it can use pngs.

    # Hyprland is **such** eye candy
    hyprland.url = github:vaxerski/Hyprland/v0.6.1beta;
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # Cachix for caching!
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, dots-manager, ... }:
    let
      system = "x86_64-linux";
      stateVersion = "22.11";

      dots-manager-path = "${dots-manager.dots-manager."${system}"}/bin";

      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix { inherit sensitive; };
        config.allowUnfree = utils.maybe sensitive.lib "sellout" false;
        # we are not ready... !
        # config.contentAddressedByDefault = false;
      };

      utils = import ./nix/utils.nix
        {
          inherit inputs self home-manager
            nixpkgs sensitive system
            pkgs stateVersion;
        };
    in
    rec {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      #
      nixosConfigurations =
        {
          "brick" = utils.mkComputer {
            machineConfig = ./nix/machines/brick.nix;
            wm = "xmonad";
            userConfigs = [ ./nix/home/daily-driver.nix ];
          };

          "exalt" = utils.mkComputer {
            machineConfig = ./nix/machines/exalt.nix;
            wm = "fb";
          };

          "lambda" = utils.mkComputer {
            machineConfig = ./nix/machines/lambda.nix;
            wm = "hyprland";
            userConfigs = [ ];
          };

          "mamba" = utils.mkComputer {
            machineConfig = ./nix/machines/mamba.nix;
            wm = "xmonad";
            userConfigs = [ ./nix/home/daily-driver.nix ];
          };

          "momento" = utils.mkComputer {
            machineConfig = ./nix/machines/momento.nix;
            wm = utils.maybe sensitive.lib "default_wm" "none";
            userConfigs = [ ./nix/home/live.nix ];
          };

          "wsl" = utils.mkComputer {
            machineConfig = ./nix/machines/wsl.nix;
            isContainer = true;
          };
        };

      # For standalone configurations
      #
      homeConfigurations = nixpkgs.lib.foldr (a: b: a // b) { } (map utils.mkHome [
        "${sensitive.lib.user}"
      ]);

      lib.utils = utils;
      # Import some scripts!
    } // (import ./scripts/scripts.nix { inherit self nixpkgs pkgs sensitive dots-manager-path; });
}
