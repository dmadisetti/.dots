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
          "prowlarr.${tld}" = { port = "9696"; };
          "transmission.${tld}" = { port = "9091"; };

          # Misc
          "tensorboard.${tld}" = { port = "6006"; };
          "home.${tld}" = { port = "8123"; };
        };
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
  hardware.nvidia.package =
    pkgs.linuxKernel.packages.linux_6_1.nvidia_x11;
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

  # TODO: Move to common/home.nix
  # or maybe hass/default?
  # idk, we need to think about HACs projects too
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"

      "hue"
      "govee_ble"
      "spotify"
      "plex"
      "radarr"
      "sonarr"

      "systemmonitor"
      "transmission"
    ];
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      pyatv
      gtts
      ibeacon-ble
      getmac
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      # See https://www.home-assistant.io/integrations/systemmonitor
      sensor = [
        {
          platform = "systemmonitor";
          resources = [
            {
              type = "memory_use_percent";
            }
            {
              type = "processor_use";
            }
            {
              type = "last_boot";
            }
            {
              type = "disk_use";
              arg = "/media/external";
            }
          ];
        }
      ];
    };
  };
}
