## word.

thanks for trying the template? i spent way too much time making sure it works.

### a checklist!
these are varying degrees of optional

- [ ] [make a keybase](https://keybase.io)

if with nix

- [ ] [set up cachix](https://github.com/dmadisetti/.dots/blob/template/.github/workflows/cache.yml)
- [ ] try out some form of installation against your own repo. (`nix run github:dmadisetti/.dots#{live,install,home}`)
- [ ] (super optional) [set up a weather token](https://github.com/dmadisetti/.dots/blob/template/nix/home/programs/eww.nix)

make sure you pull and work against
[main](https://github.com/dmadisetti/.dots/compare/main...?expand=1). the
template branch will automatically be generated if you do this. try and change
github actions on the template branch though.

all user specific information will be handled by the `sensitive` flake (found
in `nix/sensitive`), that you will have to manage yourself. The flake is
modeled after
[nix/spoof](https://github.com/dmadisetti/.dots/blob/template/nix/flake.nix).
but if you install as recommended, a wizard will walk you through it. I
recommend using version control on `nix/sensitive` with
[keybase](https://book.keybase.io/git) or a private repository.

## security notice
`xmonad` may leak your anonymity if you have the weather token provisioned.
just something to think about.

---
