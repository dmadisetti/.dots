# Fantastic Fake Flake For Fooling Flake tests
# 🥸 Should be valid nix, but also double as template
{
  description = "{{user}}'s flake";

  inputs = { };

  outputs = inputs@{ self, ... }: {
    lib = {
      # TODO: Remove reference to dylan...
      user = "dylan";
      hashed = "{{hashed}}";
      paper = "{{paper}}";
      default_wm = "{{default_wm}}";
      networking = #{{#unless networking}}
        { };
      #{{else}}{{{networking}}};{{/unless}}

      certificates = [
        /* {{{certificates}}} */
      ];

      pkgs = [
        /* {{{pkgs}}} */
      ];
    };
  };
}
