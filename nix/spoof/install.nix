{
  description = "Flake for preparing system installs";
  inputs = { };
  outputs = _: {
    lib = {
      installation = {
        enable = false;
        hostname = "{{installation_hostname}}";
        hostid = "{{installation_hostid}}";
        description = "{{installation_description}}";
        category = "{{installation_category}}";
        zfs = {
          enable = true;
          pool = "{{installation_zfs_pool}}";
        };
      };
    };
  };
}
