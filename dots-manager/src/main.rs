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
        #[clap(parse(from_os_str))]
        config: Option<PathBuf>,
        /// Outfile location
        #[clap(parse(from_os_str))]
        outfile: Option<PathBuf>,
        /// The configurations to retain.
        #[clap(parse(from_str))]
        reserve: Vec<String>,
    },
    /// Remove a machine from configuration file.
    Remove {
        /// The path to the configuration file.
        #[clap(parse(from_os_str))]
        config: Option<PathBuf>,
        /// The configurations to retain.
        #[clap(parse(from_str))]
        removed: Option<String>,
        /// Outfile location
        #[clap(parse(from_os_str))]
        outfile: Option<PathBuf>,
    },
    /// Create files for installation.
    PreInstallation {
        /// Location of .dots folder for templating.
        #[clap(required = true, parse(from_os_str))]
        dots_location: PathBuf,
        /// Output directory location.
        #[clap(required = true, parse(from_os_str))]
        install_folder: PathBuf,
        /// Default json configuration
        #[clap(parse(from_os_str))]
        defaults: Option<PathBuf>,
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
        Command::Clean {
            config,
            outfile,
            reserve,
        } => {
            let reserve = if reserve.is_empty() {
                vec!["momento".to_string(), "wsl".to_string()]
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
