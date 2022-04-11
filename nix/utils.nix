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
    i3 = "x";
    sway = "wayland";
    xmonad = "x";
  };

  # home-manager on nixos
  homeConfig = user: userConfigs: wm: { ... }:
    let
      personalized_config = (./home/users + "/${user}.nix");
      user_config =
        if builtins.pathExists personalized_config then
          personalized_config else ./home/users/user.nix;
    in
    {
      imports = [ user_config ]
        ++ userConfigs
        ++ (if wms ? "${wm}" then [
        ./home/display/display.nix
        (./home/display + "/${wm}.nix")
      ] else [ ]);
    };

  # for raw home-manager configurations
  mkHome = username: {
    "${username}" =
      home-manager.lib.homeManagerConfiguration {
        inherit system username stateVersion;
        # Specify the path to your home configuration here
        configuration = import (./home/users + "/${username}.nix") {
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
    }: nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      # Arguments to pass to all modules.
      specialArgs = {
        inherit system inputs sensitive
          user self isContainer
          stateVersion;
      };
      modules = (
        [
          # System configuration for this host
          machineConfig
          ./common.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs self stateVersion; };
            home-manager.users."${user}" = homeConfig user userConfigs wm
              {
                inherit inputs system pkgs self;
              };
          }
        ] ++ extraModules ++ (if !isContainer then [
          ./common/fonts.nix
          ./common/getty.nix
          ./common/head.nix
        ] else [ ]) ++
        (if wms ? "${wm}" then [
          (./. + ("/display/" + wms."${wm}") + ".nix")
        ] else [ ])
      );
    };
}
