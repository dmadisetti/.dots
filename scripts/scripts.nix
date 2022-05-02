inputs@{ self, nixpkgs, pkgs, sensitive, dots-manager-path, ... }: {
  docker =
    let
      home = "/tmp/dots-manager-build-home";
    in
    pkgs.dockerTools.buildImage {
      name = "dots-docker";
      tag = "latest";

      # everything in this is *copied* to the root of the image
      contents = [
        self.live
        pkgs.coreutils
      ];

      runAsRoot = ''
        #!${pkgs.runtimeShell}
        mkdir -p ${home}
        echo "root:x:0:0::${home}:${pkgs.runtimeShell}" > /etc/passwd
        echo "root:!x:::::::" > /etc/shadow
        ${pkgs.dockerTools.shadowSetup}
      '';

      # Docker settings
      config = {
        Env = [
          "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          "EDITOR=${pkgs.vim}/bin/vim"
          "NIX_CONFIG=build-users-group ="
          "HOME=${home}"
          "USER=root"
        ];
        Cmd = [ "create-live" ];
        Volumes = {
          "/tmp" = { };
        };
        WorkingDir = home;
      };
    };

  live = pkgs.writeShellScriptBin "create-live" ''
    sleep 0.05
    out=$(pwd)/result
    TEMPLATE=${../nix/spoof/flake.nix}
    SELF=${self}
    PATH=${dots-manager-path}:${pkgs.nix}/bin:$PATH
    source ${./create-live.nix.sh}
  '';

  home = pkgs.writeShellScriptBin "create-home" ''
    REMOTE=${../.github/assets/remote.txt}
    SPOOF=${../nix/spoof/flake.nix}
    PATH=${dots-manager-path}:${pkgs.nix}/bin:${pkgs.home-manager}/bin:$PATH
    source ${./create-home.nix.sh}
  '';

  # Flake outputs used by hooks.
  _configs = nixpkgs.lib.strings.concatStringsSep " " (builtins.attrNames self.nixosConfigurations);
  _live = self.nixosConfigurations.momento.config.system.build.isoImage;
  _clean = pkgs.writeShellScriptBin "clean-dots" ''
    FLAKE=${../flake.nix}
    PATH=${dots-manager-path}:${pkgs.jq}/bin:$PATH
    FLAKE_USER=${sensitive.lib.user}
    source ${./clean-dots.nix.sh}
  '';
}
