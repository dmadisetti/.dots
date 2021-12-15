...
---

## NixOS install:

Set up paritions, format and mount first.

### Generate Config
```nixos-generate-config --root /mnt```

Get git!
```nix-shell -p git```

Or maybe it comes provisioned?

Then pull this repo to `/tmp`
```git clone https://github.com/dmadisetti/.dots```

Modify the configuration file to include /tmp/.dots/nix/bootstrap/bootstrap.nix
and do base nix modifications

Build that beast!
```nixos-install```

Move over `.dots` to user folder

reboot

provision dots from system generated config

```sudo nixos-rebuild switch```
