{ inputs
, self
, home-manager
, nixpkgs
, sensitive
, pkgs
, system
, stateVersion
}: rec {

  # window managers or lack thereof
  wms = {
    fb = "none";
    hyprland = "wayland";
    i3 = "x";
    sway = "wayland";
    xmonad = "x";
  };

  # helper
  maybe = set: attr: default:
    if set ? "${attr}"
    then set."${attr}" else default;

  maybeUserConfig = user:
    let personalized_config = (./home/users + "/${user}.nix");
    in
    if builtins.pathExists personalized_config then
      personalized_config
    else
      ./home/users/user.nix;

  # home-manager on nixos
  homeConfig = user: userConfigs: wm:
    { ... }: {
      imports = [ (maybeUserConfig user) ] ++ userConfigs
        ++ (if wms ? "${wm}" then [
        ./home/display/display.nix
        (./home/display + "/${wm}.nix")
      ] else
        [ ]);
    };

  # for raw home-manager configurations
  mkHome = username: {
    "${username}" = home-manager.lib.homeManagerConfiguration {
      inherit system username stateVersion pkgs;
      # Specify the path to your home configuration here
      configuration = import (maybeUserConfig username) {
        inherit inputs system pkgs self stateVersion;
      };
      extraModules = [ ./home/standalone.nix ];

      homeDirectory = "/home/${username}";
    };
  };

  # for nixos
  mkComputer =
    { machineConfig
    , user ? sensitive.lib.user
    , wm ? ""
    , extraModules ? [ ]
    , userConfigs ? [ ]
    , isContainer ? false
    }:
    nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      # Arguments to pass to all modules.
      specialArgs = {
        inherit system inputs sensitive user self isContainer stateVersion;
      };
      modules = ([
        # System configuration for this host
        machineConfig
        ./common.nix

        # home-manager configuration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs self stateVersion; };
          home-manager.users."${user}" =
            homeConfig user userConfigs wm { inherit inputs system pkgs self; };
        }
      ] ++ extraModules ++ (if !isContainer then [
        ./common/fonts.nix
        ./common/getty.nix
        ./common/head.nix
      ] else
        [ ]) ++ (if wms ? "${wm}" then
        [ (./. + ("/display/" + wms."${wm}") + ".nix") ]
      else
        [ ]));
    };
}
