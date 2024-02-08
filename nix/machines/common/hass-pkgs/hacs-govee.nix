{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hacs-govee";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "LaggAt";
    repo = pname;
    rev = "c6d28fbfc06f2650cbc4a478a028f0a922376f4b";
    sha256 = "sha256-1fHML665KwJrnLiQee0m/v+pKL4X5B6vGwPj0AYFhac=";
  };

  installPhase = ''
    mkdir -p $out/custom_components
    cp -R ./custom_components/govee $out/custom_components/hacs-govee
  '';

  meta = with lib; {
    homepage = "https://github.com/LaggAt/hacs-govee";
    license = licenses.mit;
    description = "A HACS repository for Govee light integration";
    maintainers = with maintainers; [ dmadisetti ];
  };
}
