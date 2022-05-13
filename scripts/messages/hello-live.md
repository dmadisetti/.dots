# ⚫⚫⚫s on NixOs
## it's a wizard, harry

these dots provision a **live** system configured by a secret, user-managed
flake stored in `~/.dots/nix/sensitive`. this will walk you through generating
the initial configuration. **note**:
 - the generated flake will bootstrap your disk, but not be saved directly to the system.
 - the resultant iso will boot on `tmpfs`, _this means no user data is persistent between boots_.
 - if you would like to use this iso with some persistence, try setting up a [keybase account](https://keybase.io) (there's already integration).
 - take care provisioning the [network section](https://nixos.org/manual/nixos/stable/index.html#sec-wireless) as you would probably like internet.
 - the default browser is the `tor-browser`, and the `tor` service will be automatically enabled
 - but this iso has **not** been audited. do **not** stake your life on it
