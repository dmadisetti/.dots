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
        };
        dots-manager = with pkgs;
          rustPlatform.buildRustPackage rec {
            name = "dots-manager";
            pname = "dots-manager";
            src = ./.;
            cargoLock = {
              lockFileContents = builtins.readFile ./Cargo.lock;
              outputHashes = {
                "rnix-0.10.1" = "sha256-ZC4v3439hgKpCsBwd/SxkpdHHzhH6mVPdcqdwFJxzD0=";
                "pgp-0.7.2" = "sha256-zsRtqCYVAsXpoyvXh1CO0tZr8SkG5QipfByFZRNoor0=";
              };
            };
          };
      in
      {
        inherit dots-manager;

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

        # OK for set up
        # Ask user to partition and mount their drives
        #   # install blah
        # make home/$user
        # prompt for hostname
        # clone .dots
        # copy over .dots
        # copy over sensitive flake
        # git add
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
        generate-dots = pkgs.writeShellScriptBin "generate-dots" ''
          stub=$1
          target=$2
          test -z $1 && stub=./../nix/spoof/flake.nix
          test -z $2 && target=flake.nix
          ${dots-manager}/bin/dots-manager template $stub $target;
        '';

        defaultPackage = dots-manager;
      });
}
