{
  description = "System install definition.";
  inputs = { };
  outputs = _: {
    lib = {
      installation = {
        enable = true;
        hostname = "hoss";
        hostid = "cafebabe";
        description = "a";
        category = "machines";

        zfs = {
          enable = true;
          encrypted = false;
          pool = "zoot";
          disks = [ "sdc" "sdd" "sde" "sdf" ];
          bootable = "sdb";
        };
      };
    };
  };
}
