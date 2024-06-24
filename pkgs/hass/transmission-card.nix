{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "transmission-card";
  version = "0.15.3";

  src = fetchFromGitHub {
    # https://github.com/AnotherGroupChat/transmission-card
    owner = "amaximus";
    repo = pname;
    rev = version;
    sha256 = "sha256-a4YdZb9p+NhTq4s1PdrlhC2f5Vk6jRKRIbb7b8E9A4s=";
  };

  installPhase = ''
    mkdir -p $out/transmission-card
    cp *.js* $out/transmission-card/
    cp *.md $out/transmission-card/
    cp LICENSE $out/transmission-card/
  '';

  meta = with lib; {
    homepage = "https://github.com/amaximus/transmission-card";
    license = licenses.mit;
    description = "Custom Transmission card for Home Assistant/Lovelace";
    maintainers = with maintainers; [ dmadisetti ];
  };
}
