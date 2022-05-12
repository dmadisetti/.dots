# So hey

There are a few ways you can use this setup. Skip ahead to the part that is most pertinent to you.

From what I can tell, this is currently a {{type}} install on {{machine}}. Your
display manager is {{display}}. You [have/dont] keybase [have/dont] cachix.

wm | display | cmd
----|----|-----
sway | wayland |`sway`
xmonad | x | `startx`
i3 | x | `startx`
fb | - | `fb`
none | - | -

## default iso

If you are using the default iso (your username is `runner`)

## live install

## home install

## machine install

# commands

command | description
------|------
`+` | Adds the program to shell run `+ program -- command_with_program` for single show program usage.
`,` | Run act a command fails. Reruns the last command with assumed missing program.
`home` | Uses Home-Manager to set up user home.
`live` | Builds a live disk based on system.
`snix` | Switch and rebuild the current NixOS system
`nixos-help` | Run nixos-help but with some fail safes.
`start-daemon` | For non-NixOS (but root) start nix-daemon.
`stop-daemon` | For non-NixOS (but root) stop nix-daemon.
`unlock` | remove given flake from lock (defaults to sensitive).
`update` | Update flake and nix with correct hashs for nixpkgs.
`prs` | Applies pr diff to working branch.

### Other

#### Cachix

#### Keybase

#### Weather Token

