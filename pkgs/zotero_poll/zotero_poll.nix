{ pkgs, ... }:
    let
      ps = pkgs.python38Packages;
      zotero-cli = ps.buildPythonPackage rec {
        pname = "zotero-cli";
        version = "0.3.0";
        doCheck = false;
        propagatedBuildInputs = [ ps.setuptools-git ps.click ps.pypandoc ];
        postPatch = ''

          substituteInPlace zotero_cli/backend.py --replace 'from rauth import OAuth1Service' \
          "def OAuth1Service(*args, **kwargs): raise Exception('rauth stripped from this distribution')"

          substituteInPlace setup.py --replace '"Pyzotero >= 1.1.15",' ""
          substituteInPlace setup.py --replace '"pathlib >= 1.0.1",' ""
          substituteInPlace setup.py --replace '"rauth >= 0.7.2"' ""
        '';
        src = ps.fetchPypi {
          inherit pname version;
          sha256 = "sha256-EEg96e+OWYrqumCqDrsBNscDDlZbTsMaLQMNeYFmH6A=";
        };
      };
      pyzotero = ps.buildPythonPackage rec {
        pname = "pyzotero";
        version = "1.5.5";
        doCheck = false;
        propagatedBuildInputs = [
          ps.setuptools-scm
          ps.feedparser
          ps.pytz
          ps.bibtexparser
          ps.requests
          ps.python-dateutil
          ps.httpretty
          ps.pytest
        ];
        src = ps.fetchPypi {
          inherit pname version;
          sha256 = "sha256-4sxGPKLg13gc39COjTpq8cXo921Tfy7EXad1cujtKf0=";
        };
      };
      zotero_poll = ps.buildPythonPackage rec {
        name = "zotero_poll";
        src = ./.;
        doCheck = false;
        propagatedBuildInputs = [ ps.pybtex pyzotero ps.requests ps.prettytable zotero-cli ];
      };
      # TODO: Use agenix or move to sensitive. Ideally both
      wrapper = ''
        #!/usr/bin/env sh
        set
        while IFS= read -r line; do
          export "$line"
        done < <(gpg --quiet --decrypt ${./zotero.gpg} | awk -F= '{print $1"="$2}')

        ${zotero_poll}/bin/zotero_poll $@
      '';
    in
      (pkgs.writeScriptBin "poll_zotero" wrapper)
