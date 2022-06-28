{
  description = "dylan's flake";

  inputs = { };

  outputs = inputs@{ self, ... }: {
    lib = {

      user = /*Default is dylan (hi) for testing reasons.*/ "dylan";
      # Change this with `mkpasswd -m sha512crypt`.
      hashed = "$6$jiNhNjISaB74OuPd$.YAktWRw.t0uCnlIyPDiE4CAj7i8knSZpDPx.snrvshaJ7rRYwbEJINryNCbHOyue67gfw.Qsf3eOptlfLNxp0";
      # Defaults to "/home/dylan/.dots"
      # You can change this manually. Just sure make you manually move the folder.
      dots = "/home/dylan/.dots";

      default_wm = "hyprland";
      networking = /*Networking 📡📡📡*/{
        wireless = {
          enable = true;
          userControlled.enable = true;
          interfaces = [ "wlp4s0" ];
          networks = {
            "my_ssid" = {
              "psk" = "my passphrase";
            };
          };
        };
      };

      sshd = {
        enable = /*Disabled for live images.*/ false;
        port = /**/ 22;
        #
      };
      keybase = {
        enable = /*Only relevant for live images.*/ false;
        username = "";
        paper = '''';
      };
      git = {
        enable = /*User particular information.*/ false;
        name = "";
        email = "";
        signing = {
          enable = /*Enforce signatures.*/ false;
          key = "";
        };
      };
      certificates = {
        #
      };

      # getty can be just as pretty as lightdm imho.
      # example getty response
      #  ▄▄▄▄▄▄▄   ▄ ▄▄ ▄  ▄▄▄ ▄▄▄▄▄▄▄  Linux \r (\m)
      #  █ ▄▄▄ █ ▀ ▀ ▄█▀█▀   ▄ █ ▄▄▄ █  nixpkgs/${pkgs_rev}
      #  █ ███ █ ▀█▀ ▀ ▀ █▀ ▄▄ █ ███ █  dots/${dots_rev}
      #  █▄▄▄▄▄█ █▀▄▀█ ▄▀█▀█ █ █▄▄▄▄▄█  \d
      #  ▄▄▄▄▄ ▄▄▄█▀█  ▀▄▀▄▀█▀▄ ▄ ▄ ▄
      #  █▄▀██▀▄▄█ █ ▀██▄██▀▀██▀██▀▀▀▀
      #  ▀▄█▄ █▄▄▀▄▄ █▀▄ ▀▄█▄▀ ▀ ▀█▄▄▄
      #  ▀███ ▄▄█▄ ▄▄▄  ▄▀█▀▀▀ ▀▀█▀ ▀▀
      #  ██▀ ▀▀▄█▀ ██  ▀▀▀▄▀ █▀ █▀▀▄▄
      #  █▀▀ ▀█▄▀ ▀▄ ▀██▄█  ▀██ ▀▀██▀▀
      #  █ ▄█▀▄▄ ▄ ▀ █▀▄ ▀▄▀▀▄█▄█▄▄▄ ▄
      #  ▄▄▄▄▄▄▄ █▄ ▄▄  ▄▀ ▀██ ▄ █ █▀▀
      #  █ ▄▄▄ █ ▄ ██  ▀ ▀▄ ▀█▄▄▄█▀▄▀
      #  █ ███ █ █   ▀██▄▀▄███ ▄▄▄▄▄█▀
      #  █▄▄▄▄▄█ █ ▄ █▀▄▀ ▄ ▄▀█ █ ▀▄▀
      #
      getty = pkgs_rev: dots_rev: ''

 █▀▀▀▀▀█   ▀███▄▄ █▀▀▀ ▄▀  █▀▀▀▀▀█  Linux \r (\m)
 █ ███ █ ██▀▄▄▀▄██▀▀ █▄▄▀█ █ ███ █  nixpkgs/${pkgs_rev}
 █ ▀▀▀ █ █▀▄▄▀  █▄▀█ ▄ ▄ █ █ ▀▀▀ █  dots/${dots_rev}
 ▀▀▀▀▀▀▀ █ ▀ █ ▀▄▀ █ ▀▄█▄▀ ▀▀▀▀▀▀▀  \d
 █ █▀█▀▀  ██▄ ▀▀▀█▀▄▄█▄▀█▀ ██▀▀▀▄▄
 ▄ ▄ ▀█▀ ▄▀█ ▀ ▄▀▀ ▀  █▄ █  ▄▀██▀
 ▀█▄  █▀ ▄█▄▄▀▄▄█▄ ▀ ▄▀▄▄██▄ ▀▄▄▄▄
 ▄  █▄▄▀▀▀▄ ▄▀██ ▄  █▄▄▀ ▀  █ ▄▄▀
  ▀▀▀█▀▀▀ ▄▄▀█   ██ █  ▀▄█▀▄ ▀▄ ▀▄
 ▄ ▄▀██▀▄▀ ▀▄▄▀▄███▄▄▄ ▀ █ ▄ ▀▄█▄
 ▄▄██▄█▀ ███ ▀ ██▀▄▄▀▀█▀█▀▀▄█▀▄▄▀▄
 █  ▄▀ ▀ ▄█ ▄▄▄ █▀ ▀ ▀▄▀  ▀█▄▄██▀
 ▀  ▀▀▀▀▀█▄█▀███▀█▀█▄ ▄▀▄█▀▀▀█▀▄▀█
 █▀▀▀▀▀█ ▄▄ ▄ █ ██ ▀▄██▄██ ▀ ███▀▄
 █ ███ █ █ ▄▀█▄█▄▄ ▀ ▄▀▄▄██▀██ ▄ ▄
 █ ▀▀▀ █ ▀▄▀▀▄▄  ▄ ██▄█▄▄ ▄██▄▄▄
 ▀▀▀▀▀▀▀ ▀ ▀      ▀ ▀  ▀▀▀▀▀ ▀▀ ▀

      '';
    };
  };
}
