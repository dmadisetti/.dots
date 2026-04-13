{ stdenv
, lib
, fetchFromGitHub
, buildHomeAssistantComponent

, home-assistant
}:

buildHomeAssistantComponent rec {
  owner = "cyberjunky";
  domain = "garmin_connect";
  version = "0.2.30";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "home-assistant-garmin_connect";
    tag = version;
    hash = "sha256-Gxz0mKVgs2o7IlhGJkz4JlKRb448IRFqK87Kn+Gebkk=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    garminconnect
    tzlocal
  ];

  meta = with lib; {
    homepage = "https://github.com/cyberjunky/home-assistant-garmin_connect";
    license = licenses.mit;
    description = "Garmin Connect integration for Home Assistant";
    maintainers = with maintainers; [ dmadisetti ];
  };
}
