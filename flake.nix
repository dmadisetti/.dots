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
#    • exalt → Craptop converted for Nix hacking
#    • gce → Google Compute Engine image for server
#    • lambda → Main workstation with nvidia drivers and plex
#    • mamba → Dualboot Thinkpad daily driver
#    • wsl → WSL on the daily driver.
#
# A fair bit of inspiration from github:srid/nixos-config
{
  description = "⚫⚫⚫s on NixOS";

  inputs = rec {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official nix cache.
    # nixpkgs.url = "/home/user/src/nixpkgs-local?cache-bust=4";
    # TODO: Change to patch system NixOs/nix/issues#3920
    nixpkgs.url = github:nixos/nixpkgs/7e7c39ea35c5cdd002cd4588b03a3fb9ece6fad9;
    nixos-hardware.url = github:NixOS/nixos-hardware;

    # Really just to streamline deps.
    systems.url = github:nix-systems/default;
    flake-utils.url = github:numtide/flake-utils;
    flake-utils.inputs.systems.follows = "systems";

    # Build our own wsl
    nixos-wsl.url = github:nix-community/NixOS-WSL;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.inputs.flake-utils.follows = "flake-utils";

    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Wait for internal submodules
    # see: NixOS/nix/issues/5497
    # You can set this to sensitive manually with /path?cache-bush=0 but cache
    # invalidation is hard. Just increment/decrement around or run the fish
    # command `unlock`, which will scrub flake.lock
    # Alternatively pointing to spoof and overriding the flake seems to work
    # best.
    sensitive.url = "path:./nix/spoof";
    sensitive.inputs.nixpkgs.follows = "nixpkgs";

    # dots manager
    dots-manager.url = "path:./dots-manager";
    dots-manager.inputs.nixpkgs.follows = "nixpkgs";
    dots-manager.inputs.flake-utils.follows = "flake-utils";

    # Common Grub2 themes
    grub2-themes.url = github:AnotherGroupChat/grub2-themes-png;
    grub2-themes.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland is **such** eye candy
    hyprland.url = github:hyprwm/Hyprland/v0.41.2;
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.systems.follows = "systems";

    # Pretty spotify
    spicetify-nix.url = github:the-argus/spicetify-nix;
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.flake-utils.follows = "flake-utils";

    # Cachix for caching!
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, dots-manager, ... }:
    let
      system = "x86_64-linux";
      stateVersion = "24.05";

      dots-manager-path = "${dots-manager.dots-manager."${system}"}/bin";

      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix { inherit sensitive inputs; };
        config.allowUnfree = sensitive.lib.sellout or false;
        # allow X to be installed if you don't have unfree enabled already
        # You may have to flush sensitive from lock for this to work with
        # changes.
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg)
          (if sensitive.lib ? unfree then sensitive.lib.unfree else []);

        # Hopefully empty, but needed sometimes.
        config.permittedInsecurePackages =
          (if sensitive.lib ? insecure then sensitive.lib.insecure else []);

        # Does it work ?!
        # Standard cache is NOT set.
        # Maybe will finish compiling by the heat death of universe.
        config.contentAddressedByDefault = false;
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
      nixosConfigurations = {
          exalt = utils.mkComputer {
            machineConfig = ./nix/machines/exalt.nix;
            wm = "fb";
          };

          lambda = utils.mkComputer {
            machineConfig = ./nix/machines/lambda.nix;
            wm = "xmonad";
            userConfigs = [ ./nix/home/daily-driver.nix ];
          };

          mamba = utils.mkComputer {
            machineConfig = ./nix/machines/mamba.nix;
            wm = "xmonad";
            userConfigs = [ ./nix/home/daily-driver.nix ];
          };

          momento = utils.mkComputer {
            machineConfig = ./nix/machines/momento.nix;
            wm = sensitive.lib.default_wm or "none";
            userConfigs = [ ./nix/home/live.nix ];
          };

          wsl = utils.mkComputer {
            machineConfig = ./nix/machines/wsl.nix;
            isContainer = true;
          };

          gce = utils.mkComputer {
            machineConfig = ./nix/machines/gce.nix;
          };
        };

      # For standalone configurations
      #
      homeConfigurations = nixpkgs.lib.foldr (a: b: a // b) { } (map utils.mkHome [
        "${sensitive.lib.user}"
      ]);

      lib.utils = utils;
      # Import some scripts!
    } // (import ./scripts/scripts.nix {
      inherit self nixpkgs pkgs sensitive
        dots-manager-path;
    });
}
