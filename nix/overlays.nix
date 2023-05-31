{ sensitive }: [
  (self: super: {
    # Until nixpkgs#215316 is resolved
    transmission = super.transmission.overrideAttrs (old: {
      patches = [ ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ super.python3 ];
      src = super.fetchFromGitHub {
        owner = "transmission";
        repo = "transmission";
        rev = "4.0.2";
        hash = "sha256-DaaJnnWEZOl6zLVxgg+U8C5ztv7Iq0wJ9yle0Gxwybc=";
        fetchSubmodules = true;
      };
    });
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
  (self: super: {
    plexRaw = super.plexRaw.overrideAttrs (_: rec {
      # Pin because something is weird with the transcoder of 699
      # version = "1.32.2.7100-248a2daf0";
      # version = "1.32.1.6999-91e1e2e2c";
      version = "1.32.0.6973-a787c5a8e";
      # I don't need it, so turn it off...
      postInstall = ''
        chmod -x "$out/lib/plexmediaserver/Plex Tuner Service"
      '';
      # Fetch the source
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "sha256-fwMD/vYdwMrUvDB7JmMmVCt47ZtD17zk3bfIuO91dH8=";
        # sha256 = "sha256-sXIK72mjYvmn5k6g4nxdR794ie78F8bSnRA2oLkF2Vc=";
      };
    });
  })
  (_: pkgs: {
    # ripped off nur/berbiche
    mpvpaper = with pkgs; stdenv.mkDerivation rec {
      pname = "mpvpaper";
      version = "f65700a";

      src = fetchFromGitHub {
        owner = "GhostNaN";
        repo = "mpvpaper";
        rev = version;
        hash = "sha256-h+YJ4YGVGGgInVgm3NbXQIbrxkMOD/HtBnCzkTcRXH8=";
      };

      nativeBuildInputs = [ pkg-config meson ninja cmake ];

      buildInputs = [ wayland wayland-protocols mpv wlroots cairo ];

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
