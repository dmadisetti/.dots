# Agenix secrets configuration
{ config, lib, pkgs, sensitive, ... }:
let
  secrets = sensitive.lib.secrets or null;
in
lib.mkIf (secrets != null) {
  age.identityPaths = secrets.identityPaths;
  age.secrets = secrets.items;
}
