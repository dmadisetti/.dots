# ❄️ 
# » Implemented devices:
#    • momento → Live USB stick with configs for amnesiac + installs
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
    nixpkgs.url = github:nixos/nixpkgs/1ffba9f2f683063c2b14c9f4d12c55ad5f4ed887;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

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

    # Cachix for caching!
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, sensitive, dots-manager, ... }:
    let
      system = "x86_64-linux";
      stateVersion = "22.05";

      dots-manager-path = "${dots-manager.dots-manager."${system}"}/bin";

      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./nix/overlays.nix { inherit sensitive; };
        config.allowUnfree = false;
      };

      utils = import ./nix/utils.nix
        {
          inherit inputs self home-manager
            nixpkgs sensitive system
            pkgs stateVersion;
        };
    in
    {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      #
      nixosConfigurations =
        {
          "momento" = utils.mkComputer {
            machineConfig = ./nix/machines/momento.nix;
            wm = "sway";
            userConfigs = [ ./nix/home/live.nix ];
          };
        };

      # For standalone configurations
      #
      homeConfigurations = nixpkgs.lib.foldr (a: b: a // b) { } (map utils.mkHome [
        "${sensitive.lib.user}"
      ]);

      # Technically not allowed (warnings thrown), but whatever.
      live = pkgs.writeShellScriptBin "create-live" ''
        out=$(pwd)/result
        TEMPLATE=${./nix/spoof/flake.nix}
        SELF=${self}
        PATH=${dots-manager-path}:${pkgs.nix}/bin:$PATH
        source ${./scripts/create-live.nix.sh}
      '';

      home = pkgs.writeShellScriptBin "create-home" ''
        REMOTE=${./.github/assets/remote.txt}
        SPOOF=${./nix/spoof/flake.nix}
        PATH=${dots-manager-path}:${pkgs.nix}/bin:${pkgs.home-manager}/bin:$PATH
        source ${./scripts/create-home.nix.sh}
      '';

      # Flake outputs used by hooks.
      _configs = nixpkgs.lib.strings.concatStringsSep " " (builtins.attrNames self.nixosConfigurations);
      _live = self.nixosConfigurations.momento.config.system.build.isoImage;
      _clean = pkgs.writeShellScriptBin "clean-dots" ''
        FLAKE=${./flake.nix}
        PATH=${dots-manager-path}:${pkgs.jq}/bin:$PATH
        FLAKE_USER=${sensitive.lib.user}
        source ${./scripts/clean-dots.nix.sh}
      '';
    };
}

