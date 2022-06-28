{
  description = "System install definition.";
  inputs = { };
  outputs = _: {
    lib = {
      installation = {
        enable = true;
        hostname = "{{installation_hostname}}";
        hostid = "{{installation_hostid}}";
        description = "{{installation_description}}";
        category = "{{installation_category}}";

        zfs = {
          enable = true;
          encrypted = false;
          pool = "{{installation_zfs_pool}}";
          disks = [ "{{{installation_zfs_disks}}}" ];
          bootable = "{{installation_zfs_bootable}}";
        };
      };
    };
  };
}
