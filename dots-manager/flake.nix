{
  description = "Flake to manage nix dot configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        dots-manager = with pkgs;
          rustPlatform.buildRustPackage rec {
            name = "dots-manager";
            pname = "dots-manager";
            src = ./.;
            cargoLock =
              let
                fixupLockFile = path: (builtins.readFile path);
              in
              {
                lockFileContents = fixupLockFile ./Cargo.lock;
                outputHashes = {
                  "rnix-0.10.1" = "sha256-R7kf/XE0EzfS0DUI3V++OAoL0a5i86P7wTz0zjQs3Po=";
                };
              };
          };
      in
      {
        devShell = with pkgs;
          mkShell {
            buildInputs = [
              openssl
              rustc
              rustfmt
            ];
            packages = [
              # app packages
              cargo
              rustup
              openssl
              pkg-config
            ];
          };
        dots-manager = dots-manager;

        # OK for set up
        # Ask user to partition and mount their drives
        #   # install blah
        # make home/$user
        # prompt for templated github
        # prompt for hostname
        # clone .dots
        # copy over .dots
        # copy over sensitive flake
        # git add
        # sed readme
        # nixos-generate-config --root --dir . --show-hardware-config > host.nix
        # drop into dots-manager editor
        # nixos-install --root blah --flake  -j auto
        # congrats message !

        # check dots
        #    if not clone
        # check sensitive
        #   if not prompt
        # build flake
        # prompt for dd
        defaultPackage = pkgs.writeShellScriptBin "generate-dots" ''
          stub=$1
          target=$2
          test -z $1 && stub=$HOME/.dots/nix/spoof/flake.nix
          test -z $2 && target=$out/flake.nix
          ${dots-manager}/bin/dots-manager template $stub $target;
        '';
      });
}
