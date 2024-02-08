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
              };
            };
          };
      in
      {
        inherit dots-manager;

        devShell = with pkgs;
          mkShell {
            packages = [
              openssl
              rustc
              rustfmt
              # app packages
              cargo
              clippy
              rustup
              pkg-config
            ];
          };

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
