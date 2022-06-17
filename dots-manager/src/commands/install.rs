use std::error::Error;

use std::path::PathBuf;

use crate::config::parse_system;

pub fn install(file: PathBuf, data: JsonValue) -> Result<(), Box<dyn Error>> {
    let mut system = parse_system(file)?;
    system.add_config(config, data)?;

    println!("{}", system.render()?);

    Ok(())
}
