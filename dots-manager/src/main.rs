extern crate dots_manager;

use std::error::Error;
use std::path::PathBuf;

use clap::{Parser, Subcommand};

use dots_manager::commands::clean;
use dots_manager::commands::install;
use dots_manager::commands::template;

/// Manage Nix configuration files.
#[derive(Debug, Subcommand)]
enum Command {
    /// Clean up the configuration file.
    Clean {
        /// The path to the configuration file.
        #[clap(value_parser)]
        config: Option<PathBuf>,
        /// Outfile location
        #[clap(value_parser)]
        outfile: Option<PathBuf>,
        /// The configurations to retain.
        reserve: Vec<String>,
    },
    /// Remove a machine from configuration file.
    Remove {
        /// The path to the configuration file.
        #[clap(value_parser)]
        config: Option<PathBuf>,
        /// Outfile location
        #[clap(value_parser)]
        outfile: Option<PathBuf>,
        /// The configurations to remove.
        removed: Option<String>,
    },
    /// Create files for installation.
    PreInstallation {
        /// Location of .dots folder for templating.
        #[clap(required = true, value_parser)]
        dots_location: PathBuf,
        /// Output directory location.
        #[clap(required = true, value_parser)]
        install_folder: PathBuf,
        /// Default json configuration
        #[clap(value_parser)]
        defaults: Option<PathBuf>,
    },
    /// Template a configuration file.
    Template {
        /// Template path for use
        #[clap(required = true, value_parser)]
        template: PathBuf,
        /// Outfile location
        #[clap(value_parser)]
        outfile: Option<PathBuf>,
        /// Default json configuration
        #[clap(value_parser)]
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
        Command::Clean {
            config,
            outfile,
            reserve,
        } => {
            let reserve = if reserve.is_empty() {
                vec!["momento".to_string(), "wsl".to_string(), "gce".to_string()]
            } else {
                reserve
            };
            clean::clean(config, reserve, outfile)
        }
        Command::Remove {
            config,
            removed,
            outfile,
        } => clean::remove(config, removed, outfile),
        Command::PreInstallation {
            dots_location,
            install_folder,
            defaults,
        } => install::preinstall(dots_location, install_folder, defaults),
        Command::Template {
            template,
            outfile,
            defaults,
        } => template::config_template(template, defaults, outfile),
    }
}
