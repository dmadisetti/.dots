use std::error::Error;

use std::path::PathBuf;

use crate::config::parse_system;

pub fn clean(file: PathBuf, reserved: Vec<String>) -> Result<(), Box<dyn Error>> {
    let mut system = parse_system(file)?;
    let configs = system.list_configs();
    let configs = configs.iter().filter(|x| !reserved.contains(x));
    for config in configs {
        system.remove_config(config);
    }

    println!("{}", system.render()?);

    Ok(())
}
