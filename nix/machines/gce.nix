# GCE configuration
{ lib, pkgs, user, config, modulesPath, self, sensitive, ... }:
let
  configFile = pkgs.writeText "configuration.nix" ''
    # Configured through flakes
  '';
in
rec {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/virtualisation/google-compute-config.nix"
  ];
  users.users."${user}".initialHashedPassword = sensitive.lib.hashed;
  environment.sessionVariables = { IS_GCE = "1"; };

  # Great idea from cole-h/nixos-config, meaning we don't have to provide root
  # to anyone, and can deploy remotely.
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Basically a rip off of google-compute-image.nix, but copied so we have more
  # granular control.
  system.build.googleComputeImage = import "${modulesPath}/../lib/make-disk-image.nix" {
    name = "google-compute-image";
    postVM = ''
      PATH=$PATH:${with pkgs; lib.makeBinPath [ gnutar gzip ]}
      pushd $out
      mv $diskImage disk.raw
      tar -Sc disk.raw | gzip -6 > \
        nixos-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.raw.tar.gz
      rm $out/disk.raw
      popd
    '';
    format = "raw";
    configFile = configFile;
    diskSize = "auto";
    inherit config lib pkgs;
    additionalPaths = [ ../. ../../. ];
  };
}
