{ sensitive, inputs }: [
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
