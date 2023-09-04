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
#    • gce → Google Compute Engine image for server
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
    # nixpkgs.url = "/home/user/src/nixpkgs-local?cache-bust=4";
    # TODO: Change to patch system NixOs/nix/issues#3920
    nixpkgs.url = github:nixos/nixpkgs/e56990880811a451abd32515698c712788be5720;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Really just to streamline deps.
    flake-utils.url = github:numtide/flake-utils;

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
    hyprland.url = github:vaxerski/Hyprland/v0.28.0;
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

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
      stateVersion = "23.11";

      dots-manager-path = "${dots-manager.dots-manager."${system}"}/bin";

      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix { inherit sensitive; };
        config.allowUnfree = sensitive.lib.sellout or false;
        # allow X to be installed if you don't have unfree enabled already
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg)
          (if sensitive.lib ? unfree then sensitive.lib.unfree else [ ]);
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
      nixosConfigurations =


        {
          gce = utils.mkComputer {
            machineConfig = ./nix/machines/gce.nix;
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

