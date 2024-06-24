{ stdenv
, lib
, fetchFromGitHub
, buildHomeAssistantComponent

, home-assistant
}:

buildHomeAssistantComponent rec {
  owner = "cyberjunky";
  domain = "garmin_connect";
  version = "a12306d79d14d721b8a634820c529825250c736e";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-garmin_connect";
    rev = version;
    sha256 = "sha256-pcJ6y3Ntab7fb0tfvL2HZ78dFQBVdhOhqBhiD3gQac4=";
  };

  patchPhase = ''
    sed -i 's/garminconnect==0.2.12/garminconnect>=0.2.15/g' \
      custom_components/garmin_connect/manifest.json

    sed -i 's/hass.config_entries.async_setup_platforms/await hass.config_entries.async_forward_entry_setups/g' \
      custom_components/garmin_connect/__init__.py
  '';

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
