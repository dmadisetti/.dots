# Machine level configuaration for lambda
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, self, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/lambda.nix

      (import ./common/fancy-grub.nix {
        splash = ../../dot/backgrounds/lambda-grub.jpg;
        short = true;
      })
      (import ./common/hostapd.nix {
        dev = {
          ap = "wlo1";
          out = "enp3s0";
        };
        ssid = ''🧐'';
      })
      (import ./common/nginx.nix rec {
        tld = "ave";
        cert =
          if (self.inputs.sensitive.lib.certificates ? ave) then {
            inherit (self.inputs.sensitive.lib.certificates.ave) key cert;
          } else null;
        proxies = {
          "notebook.${tld}" = {
            port = "8000";
            extra = ''
              proxy_set_header Host $host;'';
          };
          "~^(?<sub>.+)?\\.notebook.${tld}$" = { port = "800$sub"; };
          "~^(?<port>\\d+)?\\.port.${tld}$" = { port = "$port"; };
          "notes.${tld}" = {
            port = "9000";
            extra = ''
              add_header Access-Control-Allow-Origin *;
            '';
          };

          # Plex relevant
          "plex.${tld}" = { port = "32400"; };
          "sonarr.${tld}" = { port = "8989"; };
          "radarr.${tld}" = { port = "7878"; };
          "readarr.${tld}" = { port = "8787"; };
          "kavita.${tld}" = {
            port = "5000";
            # Annoyingly requires header to be set, even though there are
            # options to change the host.
            extra = ''
              proxy_set_header Host $host;
            '';
          };
          "prowlarr.${tld}" = { port = "9696"; };
          "transmission.${tld}" = { port = "9091"; };

          # Misc
          "tensorboard.${tld}" = {
            port = "6006";
            extra = ''
            '';
          };
          "home.${tld}" = { port = "8123"; };
        };
      })
      (import ./common/home-assistant.nix {
        extraComponents = [
          # Having hue forces port 80
          "hue"
          "spotify"
          "plex"
          "radarr"
          "sonarr"
          "transmission"
        ];
        customComponents = [
          pkgs.home-assistant-custom-components.govee-lan
        ];
        customModules = [
          # (pkgs.callPackage ./common/hass-pkgs/transmission-card.nix { })
          (pkgs.callPackage ./common/hass-pkgs/garmin.nix { })
          pkgs.home-assistant-custom-lovelace-modules.mushroom
        ];
      })
    ] ++ (if self.inputs.sensitive.lib.sellout or false
    then [ ./common/plex.nix ] else [ ]) ++ (
      if self.inputs.sensitive.lib ? ssh-boot then
        [
          (import ./common/ssh-boot.nix {
            hostKey = self.inputs.sensitive.lib.ssh-boot.key;
            authorizedKey = self.inputs.sensitive.lib.ssh-boot.pub;
          })
        ] else [ ]
    );

  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  networking.hostName = "lambda";
  networking.hostId = "001a3bda";

  i18n.defaultLocale = "en_US.UTF-8";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = pkgs.linuxKernel.packages.linux_6_6.nvidia_x11;
  hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.prime.offload.enable = true;
  environment.systemPackages = with pkgs; [ nvidia-docker ];
  # something broke though
  services.xserver.dpi = 110;
  environment.variables = { GDK_SCALE = "0.3"; };

  # Bluetooth
  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth.enable = true;
  # Don't power up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = false;
  boot.extraModprobeConfig = "options bluetooth disable_ertm=1 ";

  # lambda specific programs
  programs.singularity.enable = true;

  /* zfs */
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "zoot" ];
    };
  };

  # Boo printing
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.cnijfilter2 ];

  # For Gyro switch controllers
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
  '';
}
