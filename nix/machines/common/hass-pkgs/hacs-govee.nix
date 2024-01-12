{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hacs-govee";

  src = fetchFromGitHub {
    # https://github.com/AnotherGroupChat/transmission-card
    owner = "LaggAt";
    repo = pname;
    rev = "c6d28fbfc06f2650cbc4a478a028f0a922376f4b";
    sha256 = "sha256-a4YdZb9p+NhTq5s1PdrlhC2f5Vk6jRKRIbb7b8E9A4s=";
  };

  installPhase = ''
    mkdir -p $out/custom_components
    cp -R $out/custom_components/govee $out/custom_components
  '';

  meta = with lib; {
    homepage = "https://github.com/amaximus/transmission-card";
    license = licenses.mit;
    description = "Custom Transmission card for Home Assistant/Lovelace";
    maintainers = with maintainers; [ dmadisetti ];
  };
}
