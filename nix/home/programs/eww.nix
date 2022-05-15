{ inputs, pkgs, home, ... }:
let
  weather =
    if inputs.sensitive.lib ? weather
      && inputs.sensitive.lib.weather.enable then
      inputs.sensitive.lib.weather
    else {
      key = "";
      city = "";
    };
in
{
  imports = [ ];

  home.packages = with pkgs;
    [
      eww # bars and widgets
    ];

  home.sessionVariables = {
    WEATHER_KEY = weather.key;
    WEATHER_CITY = weather.city;
  };
}
