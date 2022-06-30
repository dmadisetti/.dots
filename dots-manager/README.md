# dots manager

pretty much managed through flake scripts and fish functions. Refer to 
[scripts help](../scripts/messages/help.md), (or just run `dots-help`).

but just in case

### usage
```
dots-manager 0.1.0
dmadisetti <dylan@madisetti.me>
Wizard for dots install

USAGE:
    dots-manager <SUBCOMMAND>

OPTIONS:
    -h, --help       Print help information
    -V, --version    Print version information

SUBCOMMANDS:
    clean               Clean up the configuration file
    help                Print this message or the help of the given subcommand(s)
    pre-installation    Create files for installation
    remove              Remove a machine from configuration file
    template            Template a configuration file
```

so the dream is just to read + manage from nix modules, but not at a scale
where that really makes sense, so one off definitions seem fine for me
right now.
