use std::error::Error;

use std::path::PathBuf;

use requestty::Question;

use crate::config::parse_system;
use crate::utils::{maybe_write, default_config};

pub fn clean(
    config_file: Option<PathBuf>,
    reserved: Vec<String>,
    outfile: Option<PathBuf>,
) -> Result<(), Box<dyn Error>> {
    let file = default_config(config_file);
    let mut system = parse_system(file)?;
    let configs = system.list_configs();
    let configs = configs.iter().filter(|x| !reserved.contains(x));
    for config in configs {
        system.remove_config(config);
    }

    maybe_write(outfile, system.render()?)
}

pub fn remove(
    config_file: Option<PathBuf>,
    removed: Option<String>,
    outfile: Option<PathBuf>,
) -> Result<(), Box<dyn Error>> {
    let file = default_config(config_file);
    let mut system = parse_system(file)?;
    let removed = match removed {
        Some(removed) => removed,
        None => {
                let response = requestty::prompt_one(
                Question::select("removal")
                    .message("Which system would you like to remove?")
                    .choices(system.list_configs())
                    .build(),
            )?
            .as_list_item()
            .map(|x| x.text.as_str().to_string())
            .ok_or("No selection")?;
            // print to provide consumers with what was removed
            eprintln!("{}", response);
            response
        },
    };
    system.remove_config(&removed);
    maybe_write(outfile, system.render()?)
}
