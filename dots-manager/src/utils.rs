use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

pub fn default_config(config: Option<PathBuf>) -> PathBuf {
    match config {
        Some(config) => config,
        None => PathBuf::from("./.dots/flake.nix"),
    }
}

pub fn maybe_write(outfile: Option<PathBuf>, attempt: String) -> Result<(), Box<dyn Error>> {
    match outfile {
        Some(outfile) => {
            let mut file = File::create(outfile)?;
            file.write_all(attempt.as_bytes())?;
        }
        None => println!("{}", attempt),
    };

    Ok(())
}
