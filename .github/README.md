<p align=center><img src=https://raw.githubusercontent.com/dmadisetti/.dots/template/.github/assets/dots.png alt=".dots logo" height=100px/></p>

## (.dots) [![this is currently](https://github.com/dmadisetti/.dots/actions/workflows/flake.yml/badge.svg?branch=main)](https://github.com/dmadisetti/.dots/actions/workflows/flake.yml)

**so** you want to steal _my_ `.dots`? that's cool, and in fact encouraged. feel free to [use this as template](https://github.com/dmadisetti/.dots/generate), i just ask you leave a star. my current systems are provisioned on [main](https://github.com/dmadisetti/.dots/tree/main).

### installation

 > **Note**
 > [first template this repository](https://github.com/dmadisetti/.dots/generate), do **not** include additional branches, and continue reading from your new repository.

if you just want my `.dots` run `setup.sh`. if you want the whole os experience, start with [a generated live disk](https://github.com/dmadisetti/.dots/actions/workflows/iso.yml) or

```bash
nix run github:dmadisetti/.dots#live; # make your own install disk (recommended)
# or
nix run github:dmadisetti/.dots#home; # install with home-manager
# or
nix run github:dmadisetti/.dots#install; # disk level installation
```

to create a live disk without `nix`:

```bash
docker run --rm -it -v/tmp:/tmp --privileged ghcr.io/dmadisetti/dots
# but TODO: remove the --privileged flag
```

and that's it. follow the wizard 🧙🏾‍♂️✨

---
<!-- anything between #examples and /examples comments will be stripped -->
<!-- #examples -->
<details open align="center"> <summary>Hyprland</summary>
  <div align="center">
  <video src="https://github.com/dmadisetti/.dots/assets/2689338/c425034a-93c4-4f4b-8ac5-7d384a891acb" width="400" >
  </video>
  </div>
</details>
<br clear="both"/>
   
<details open> <summary>XMonad</summary>
 <img src=https://user-images.githubusercontent.com/2689338/167262397-ef2f41d4-9c4f-496c-aca3-4b80ecf975b5.png align=left width=45%/>
 <img src=https://user-images.githubusercontent.com/2689338/164264993-cb3c3892-35f3-4afb-9ba9-71ba778f358d.png align=right width=45%/>
 <br clear="both"/>
</details>
 <br clear="both"/>
<!-- TODO: Add lambda --> 
<!-- /examples -->

### contribution

> **Warning**
> lol, i don't want your contributions. i'm only slightly joking. it's okay to have opinionated, individualized, hacky dots- and suggesting changes to my `.vimrc` is a personal attack.

**however**, if you provide changes that make the templating system and bootstrapping system better (or you just want to show me something cool), then i'd love your contributions. make sure that you are creating a pull request against [main](https://github.com/dmadisetti/.dots/tree/main). just note, that because these are _my_ `.dots`- i might not take _your_ suggestions. that's why i recommend [templating](https://github.com/dmadisetti/.dots/generate) over forking `:)`

### need help? [here's help.](https://github.com/dmadisetti/.dots/blob/template/scripts/messages/help.md)
