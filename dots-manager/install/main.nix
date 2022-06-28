{
  description = "System install definition.";
  inputs = { };
  outputs = _: {
    lib = {
      installation = {
        enable = true;
        hostname = "haa";
        hostid = "cafebabe";
        description = "a system nuh";
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
