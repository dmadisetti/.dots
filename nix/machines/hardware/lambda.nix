# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, user, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "r8169" ];
  boot.kernelModules = [ "r8169" "kvm-intel" "kvm" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "zoot/system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zoot/system/nix";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    {
      device = "zoot/persist";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zoot/user/home";
      fsType = "zfs";
    };

  fileSystems."/root" =
    {
      device = "zoot/user/home/root";
      fsType = "zfs";
    };

  fileSystems."/home/${user}" =
    {
      device = "zoot/user/home/${user}";
      fsType = "zfs";
    };

  fileSystems."/media" =
    {
      device = "zoot/media";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/844A-6AD8";
      fsType = "vfat";
    };

  fileSystems."/media/external" =
    {
      device = "external";
      fsType = "zfs";
      options = [ "auto" "nofail" "noatime" ];
    };

  fileSystems."/media/external/media" =
    {
      device = "external/media";
      fsType = "zfs";
      options = [ "auto" "nofail" "noatime" ];
    };

  fileSystems."/media/external/data" =
    {
      device = "external/data";
      fsType = "zfs";
      options = [ "auto" "nofail" "noatime" ];
    };

  fileSystems."/media/external/snapshots" =
    {
      device = "external/snapshots";
      fsType = "zfs";
      options = [ "auto" "nofail" "noatime" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl.driSupport32Bit = true;
}
