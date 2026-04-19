# kRPC Python client — not in nixpkgs
# https://pypi.org/project/krpc/
{ python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
  pname = "krpc";
  version = "0.5.4";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
    hash = "sha256-lbRRKggMktRaG2Drue/5KQxSY6Gf8avbNR4S/7UfthU=";
  };

  propagatedBuildInputs = with python3Packages; [
    protobuf
  ];

  nativeCheckInputs = with python3Packages; [
    setuptools
  ];

  # Tests require a running KSP instance with kRPC
  doCheck = false;

  pythonImportsCheck = [ "krpc" ];

  meta = {
    description = "Client library for kRPC, a Remote Procedure Call server for Kerbal Space Program";
    homepage = "https://krpc.github.io/krpc";
    license = python3Packages.python.meta.license;
  };
}
