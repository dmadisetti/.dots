{ stdenv
, lib
, fetchFromGitHub
, home-assistant
}:

with stdenv.mkDerivation rec {
  pname = "transmission-card";
  version = "0.15.3";

  src = fetchFromGitHub {
    # https://github.com/AnotherGroupChat/transmission-card
    owner = "amaximus";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HLY9+eXzfVasO1EVZQ46mooJ4beID01RvYo4BfjHfnc=";
  };

  installPhase = ''
    mkdir -p $out/custom_components
    cp *.js* $out/custom_components/
    cp *.md $out/custom_components/
    cp LICENSE $out/custom_components/
  '';

  meta = with lib; {
    homepage = "https://github.com/amaximus/transmission-card";
    license = licenses.mit;
    description = "Custom Transmission card for Home Assistant/Lovelace";
    maintainers = with maintainers; [ dmadisetti ];
  };
}
