extern crate dots_manager;

use std::error::Error;
use std::path::PathBuf;

use clap::{Parser, Subcommand};

use dots_manager::commands::clean::clean;
use dots_manager::commands::template::config_template;

/// Manage Nix configuration files.
#[derive(Debug, Subcommand)]
enum Command {
    /// Clean up the configuration file.
    Clean {
        /// The path to the configuration file.
        #[clap(parse(from_os_str))]
        config: Option<PathBuf>,
        /// The configurations to retain.
        #[clap(parse(from_str))]
        reserve: Vec<String>,
    },
    /// Template a configuration file.
    Template {
        /// Template path for use
        #[clap(required = true, parse(from_os_str))]
        template: PathBuf,
        /// Outfile location
        #[clap(parse(from_os_str))]
        outfile: Option<PathBuf>,
        /// Default json configuration
        #[clap(parse(from_os_str))]
        defaults: Option<PathBuf>,
    },
}

#[derive(Parser, Debug)]
#[clap(author, version, about)]
struct Cli {
    /// Subroutine to run
    #[clap(subcommand)]
    command: Command,
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Cli::parse();

    match args.command {
        Command::Clean { config, reserve } => {
            let config = match config {
                Some(config) => config,
                None => PathBuf::from("/home/dylan/.dots/flake.nix"),
            };
            let reserve = if reserve.is_empty() {
                vec!["momento".to_string()]
            } else {
                reserve
            };
            clean(config, reserve)
        }
        Command::Template { template, outfile, defaults } => config_template(template, outfile, defaults),
    }
}
