{
  description = "System install definition.";
  inputs = { };
  outputs = _: {
    lib = {
      installation = {
        enable = /*Only relevant for live images.{{#if installation}}*/ true;
        #{{else}}*/ false;{{/if}}
        hostname = "{{installation_hostname}}";
        hostid = "{{installation_hostid}}";
        description = "{{installation_description}}";
        category = "{{installation_category}}";

        # {{#unless installation_block}}
        disko = {
          enable = /*Only relevant for live images.{{#if installation_disko}}*/ true;
          #{{else}}*/ false;{{/if}}
          home = "{{installation_disko_home}}";
          tmpfs = "{{installation_disko_tmpfs}}";
        };

        zfs = {
          # If disko is not provided, just uses ./scripts/create-install.nix.sh
          enable = /*Only relevant for live images.{{#if installation_zfs}}*/ false;
          #{{else}}*/ false;{{/if}}
          encrypted = "{{installation_zfs_encrypted}}";
          pool = "{{installation_zfs_pool}}";
          disks = [ "{{{installation_zfs_disks}}}" ];
          bootable = "{{installation_zfs_bootable}}";
          cache = "{{installation_zfs_cache}}";
        };

        # {{#if never}} # Don't display, just used for templating
        block = {
          # {{hook "installation_devices"}}
          devices = {
            # Just living life on the edge. Remove if you are not interested in
            # living on the edge /s.
            # (Remove if impermanence seems insane:
            #   - https://grahamc.com/blog/erase-your-darlings/
            # )
            nodev."/" = {
              fsType = "tmpfs";
              mountOptions = [
                "size={{installation_disko_tmpfs}}G"
                "defaults"
                "mode=755"
              ];
            };
            disk = {
              home = {
                type = "disk";
                device = "{{installation_disko_home}}";
                content = {
                  type = "gpt";
                  partitions = {
                    home = {
                      size = "100%";
                      content = {
                        type = "filesystem";
                        format = "nilfs2";
                        mountpoint = "/home";
                      };
                    };
                  };
                };
              };
              # {{#each installation_devices}}
              "{{name}}" = {
                type = "disk";
                device = "{{disk}}";
                content = {
                  type = "gpt";
                  partitions = {
                    # {{#if boot}}
                    ESP = {
                      size = "64M";
                      type = "EF00";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                      };
                    };
                    # {{/if}}
                    zfs = {
                      size = "100%";
                      content = {
                        type = "zfs";
                        pool = "{{../installation_zfs_pool}}";
                      };
                    };
                  };
                };
              };
              # {{/each}}
            };

            zpool = {
              "{{installation_zfs_pool}}" = {
                type = "zpool";
                mode = {
                  topology = {
                    type = "topology";
                    vdev =
                      let
                        main = rec {
                          mode = if (length main.members) > 1 then "raidz" else "";
                          members = [ "{{{installation_zfs_disks}}}" ];
                        };
                      in
                      [ main ];
                    cache = [ "{{{installation_zfs_cache}}}" ];
                  };
                };
                rootFsOptions = {
                  compression = "zstd";
                  "com.sun:auto-snapshot" = "false";
                };
                mountpoint = "/";
                datasets = {
                  # TODO: Add encryption to store
                  nix = {
                    type = "zfs_fs";
                    mountpoint = "/nix";
                    options."com.sun:auto-snapshot" = "true";
                  };
                };
              };
            };
          };
        };
        # {{/if}}
        # {{/unless}}
      };
    };
  };
  # Expose top level attribute for disko.
  /* {{#unless installation_block}} */
  # {{else}} */ disko = {{{installation_block}}};
  # {{/unless}}
}
