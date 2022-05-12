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
        mkdir -p ${home} /etc
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
    # Sleep required for requestty
    sleep 0.05
    out=$(pwd)/result
    TEMPLATE=${../nix/spoof/flake.nix}
    SELF=${self}
    PATH=${dots-manager-path}:${pkgs.nix}/bin:$PATH
    WELCOME="$(${self._prettyprint} hello-live)"
    WAIT="$(${self._prettyprint} wait)"
    source ${./create-live.nix.sh}
    echo "Congrats 🎉! Flash $(dirname $out)/live.iso to your device of choice."
  '';

  home = pkgs.writeShellScriptBin "create-home" ''
    # Sleep required for requestty
    sleep 0.05
    REMOTE=${../.github/assets/remote.txt}
    SPOOF=${../nix/spoof/flake.nix}
    PATH=${dots-manager-path}:${pkgs.nix}/bin:${pkgs.home-manager}/bin:$PATH
    source ${./create-home.nix.sh}
  '';

  # Flake outputs used by hooks.
  _prettyprint =
    let
      messages = pkgs.stdenv.mkDerivation {
        name = "prettyprint-messages";
        src = ./messages;
        installPhase = ''
          mkdir -p $out/;
          files="*.md"
          for f in $files; do
            ${pkgs.glow}/bin/glow -s dark $f > $out/$(basename $f .md);
          done
        '';
      };
    in
    # generate messages prior to remove 20mb+ dependency of glow.
    pkgs.writeShellScriptBin "prettyprint" ''
      for msg in "$@"; do
        cat ${messages}/$(basename $msg .md) 2> /dev/null || echo "prettyprint error for $msg";
      done
    '';
  _configs = nixpkgs.lib.strings.concatStringsSep " " (builtins.attrNames self.nixosConfigurations);
  _live = self.nixosConfigurations.momento.config.system.build.isoImage;
  _clean = pkgs.writeShellScriptBin "clean-dots" ''
    FLAKE=${../flake.nix}
    PATH=${dots-manager-path}:${pkgs.jq}/bin:$PATH
    FLAKE_USER=${sensitive.lib.user}
    source ${./clean-dots.nix.sh}
  '';
}
