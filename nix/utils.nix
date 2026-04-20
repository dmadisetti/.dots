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
    openbox = "x";
    sway = "wayland";
    xmonad = "x";
    xvfb = "none";
  };

  maybeUserConfig = user:
    let personalized_config = ./home/users + "/${user}.nix";
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
        [ ]) ++ (if wm == "hyprland" then
        [ inputs.hyprland.homeManagerModules.default ] else [ ]);
    };

  # for raw home-manager configurations
  mkHome = username: {
    "${username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { 
        inherit inputs self system stateVersion; 
 cowboyPkgs = { cowboy-harness = pkgs.hello; qmd = pkgs.hello; };
      };
      modules = [
        # No NixOs
        ./home/standalone.nix

        # Specify the path to your home configuration here
        (maybeUserConfig username)

        # Set home directory
        {
          # Annoying. Not sure when this started beign required.
          nix.package = pkgs.nix;
          home = {
            inherit stateVersion username;
            homeDirectory = "/home/${username}";
          };
        }
      ];
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
      modules = [
        # System configuration for this host
        machineConfig
        ./common.nix
      ]
      # Secrets management — only activates if sensitive provides a secrets
      # block (see nix/common/age.nix). Other machines without secrets in
      # their sensitive branch are unaffected.
      ++ (if sensitive.lib ? secrets then [
        inputs.agenix.nixosModules.default
        ./common/age.nix
      ] else [ ])
      ++ [
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
        [ ]);
    };
}
