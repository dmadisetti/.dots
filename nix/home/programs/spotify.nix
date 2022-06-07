# see https://github.com/pietdevries94/spicetify-nix
{ pkgs, ... }:
let
  av = pkgs.fetchFromGitHub {
    owner = "amanharwara";
    repo = "spicetify-autoVolume";
    rev = "d7f7962724b567a8409ef2898602f2c57abddf5a";
    sha256 = "1pnya2j336f847h3vgiprdys4pl0i61ivbii1wyb7yx3wscq7ass";
  };

  # fetchFromGitHub should work too
  spicetify = fetchTarball https://github.com/pietdevries94/spicetify-nix/archive/master.tar.gz;
in
{
  imports = [ (import "${spicetify}/module.nix") ];

  programs.spicetify = {
    enable = true;
    theme = "Dribbblish";
    colorScheme = "horizon";
    enabledCustomApps = ["reddit"];
    enabledExtensions = ["newRelease.js" "autoVolume.js"];
    thirdParyExtensions = {
      "autoVolume.js" = "${av}/autoVolume.js";
    };
  };
}
