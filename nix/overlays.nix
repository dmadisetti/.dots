{ sensitive, inputs }: [
  (self: super: {
    home-assistant = super.home-assistant.override {
        packageOverrides = _: py-pkgs: {
          govee-api-laggat = py-pkgs.buildPythonPackage rec {
              pname = "govee-api-laggat";
              version = "0.2.2";
              format = "pyproject";
              nativeBuildInputs = with py-pkgs; [
                setuptools
              ];
              propagatedBuildInputs = with py-pkgs; [
                dacite
                events
                aiohttp
                certifi
                pygatt
                pexpect
              ];
              postPatch = ''
                cd ./.git-subtree/python-govee-api
                sed -i 's/"bios>=0.1.2",//g' setup.py
              '';
              src = super.fetchFromGitHub {
                owner = "LaggAt";
                repo = "hacs-govee";
                rev = "c6d28fbfc06f2650cbc4a478a028f0a922376f4b";
                sha256 = "sha256-1fHML665KwJrnLiQee0m/v+pKL4X5B6vGwPj0AYFhac=";
              };
          };
          python_otbr_api = py-pkgs.buildPythonPackage rec {
              pname = "python_otbr_api";
              version = "2.5.0";
              format = "pyproject";
              nativeBuildInputs = with py-pkgs; [
                setuptools
              ];
              propagatedBuildInputs = with py-pkgs; [
                voluptuous
                aiohttp
                bitstruct
                cryptography
              ];
              src = super.fetchFromGitHub {
                owner = "home-assistant-libs";
                repo = "python-otbr-api";
                rev = "1c386687902e0ae657f576159ff70cb99f14da82";
                hash = "sha256-YcvfkUkEVXn9SMqnxu3e26P4QmYuIW7vIycU2HpLsGM=";
              };
          };
          transmission-rpc = py-pkgs.transmission-rpc.overrideAttrs (attrs: rec {
            pname = "transmission-rpc";
            version = "6.0.0";
            src = super.fetchFromGitHub {
              owner = "Trim21";
              repo = "transmission-rpc";
              rev = "refs/tags/v${version}";
              hash = "sha256-gRyxQ6Upc1YBRhciVfyt0IGjv8K8ni4I1ODRS6o3tHA=";
            };
          });
        };
      };
  })
  (self: super: {
    picom = super.picom.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "jonaburg";
        repo = "picom";
        rev = "e3c19cd7d1108d114552267f302548c113278d45";
        sha256 = "sha256-4voCAYd0fzJHQjJo4x3RoWz5l3JJbRvgIXn1Kg6nz6Y=";
      };
    });
  })
  (self: super:
    let
      pref = "extensions.zotero.dataDir";
      path = "/home/${sensitive.lib.user}/.zotero/data";
      pref2 = "extensions.zotero.useDataDir";
    in
    {
      zotero = super.zotero.overrideAttrs (old: {
        postPatch = old.postPatch + ''
          sed -i '/pref("${pref}", .*);/c\pref("${pref}", "${path}");' defaults/preferences/zotero.js
          sed -i '/pref("${pref2}", .*);/c\pref("${pref2}", true);' defaults/preferences/zotero.js
        '';
      });
    })
  (self: super: {
    firefox = super.firefox.override {
      extraPolicies = {
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        Certificates = {
          ImportEnterpriseRoots = true;
          Install = self.lib.catAttrs "cert" (self.lib.attrValues sensitive.lib.certificates);
        };
      };
    };
  })
  (self: pkgs: {
    # ripped off nur/berbiche
    mpvpaper = pkgs.stdenv.mkDerivation rec {
      pname = "mpvpaper";
      version = "f65700a";

      src = pkgs.fetchFromGitHub {
        owner = "GhostNaN";
        repo = "mpvpaper";
        rev = version;
        hash = "sha256-h+YJ4YGVGGgInVgm3NbXQIbrxkMOD/HtBnCzkTcRXH8=";
      };
      nativeBuildInputs = with pkgs; [ pkg-config meson ninja cmake ];
      buildInputs =  [ pkgs.wayland-protocols pkgs.libGL pkgs.wayland inputs.hyprland.packages."x86_64-linux".hyprland-protocols
      inputs.hyprland.packages."x86_64-linux".wlroots-hyprland pkgs.mpv pkgs.cairo ];
      meta = {
        description = ''
          A wallpaper program for wlroots based Wayland compositors that
          allows you to play videos with mpv as your wallpaper
        '';
        homepage = "https://github.com/GhostNaN/mpvpaper";
        # license = licenses.gpl3;
      };
    };
  })
]
