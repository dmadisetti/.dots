<p align=center><img src=https://raw.githubusercontent.com/dmadisetti/.dots/template/.github/assets/dots.png alt=".dots logo" height=100px/></p>

## (.dots) [![this is currently](https://github.com/dmadisetti/.dots/actions/workflows/flake.yml/badge.svg?branch=main)](https://github.com/dmadisetti/.dots/actions/workflows/flake.yml)

**so** you want to steal _my_ `.dots`? that's cool, and in fact encouraged. feel free to [use this as template](https://github.com/dmadisetti/.dots/generate), i just ask you leave a star. my current systems are provisioned on [main](https://github.com/dmadisetti/.dots/tree/main).

### installation

 > [first template this repository](https://github.com/dmadisetti/.dots/generate), do **not** include additional branches, and continue reading from your new repository.

if you just want my `.dots` run `setup.sh`. if you want the whole os experience, start with the live disk or

```bash
nix run github:dmadisetti/.dots#live;
# or nix run github:dmadisetti/.dots#install if you don't want the live disk, but you're missing out.
```

and that's it. follow the wizard 🧙🏾‍♂️✨

---
<!-- anything between #examples and /examples comments will be stripped -->
<!-- #examples -->
<img src=https://user-images.githubusercontent.com/2689338/164264993-cb3c3892-35f3-4afb-9ba9-71ba778f358d.png align=left width=50%/>
<pre>
dylan@mamba
-----------
OS: NixOS 22.05 (Quokka) x86_64
Kernel: 5.15.34
Packages: 457 (nix-system), 856 (nix-user)
Shell: fish 3.4.1
Resolution: 1920x1080
WM: xmonad
Terminal: kitty
Pkgs: polybar, rofi, eww, dunst, zathura
</pre>
<br clear="both"/>
<!-- /examples -->

### contribution

lol, i don't want your contributions. i'm only slightly joking. it's okay to have opinionated, individualized, hacky dots- and suggesting changes to my `.vimrc` is a personal attack.

however, if you provide changes that make the templating system and bootstrapping system better (or you just want to show me something cool), then i'd love your contributions. make sure that you are creating a pull request against [main](https://github.com/dmadisetti/.dots/tree/main). just note, that because these are _my_ `.dots`- i might not take _your_ suggestions. that's why i recommend [templating](https://github.com/dmadisetti/.dots/generate) over forking `:)`
