use std::error::Error;
use std::path::PathBuf;

use std::fs::read_to_string;

use crate::utils;
use crate::commands::template;
use crate::config::parse_system;
use crate::config::Config;

use requestty::Question;
use serde_json::json;

pub fn preinstall(
    dots_location: PathBuf,
    install_folder: PathBuf,
    defaults: Option<PathBuf>,
) -> Result<(), Box<dyn Error>> {
    let mut skip = false;
    let mut defaults = match requestty::prompt_one(
        Question::select("load")
            .message("How should we provision this install?")
            .choices(vec![
                "run wizard from the top",
                "use inferred sensitive values",
                "use current sensitive flake",
            ])
            .build(),
    )?
    .as_list_item()
    .map(|x| x.index)
    {
        Some(0) => json!({}),
        Some(1) => template::load_defaults(defaults)?,
        Some(2) => {
            skip = true;
            json!({"dont_refresh": true})
        }
        _ => return Err("bad selection".into()),
    };

    let output = std::process::Command::new("bash")
        .arg("-c")
        .arg("lsblk -JSo name,model,size")
        .output()
        .expect("failed to execute process");

    defaults["installation"] = json!({
        "installation_zfs": {
            "installation_zfs_available": serde_json::from_str::<serde_json::Value>(std::str::from_utf8(&output.stdout)?)?
            ["blockdevices"]
            .clone()
    }
    });

    // template flake
    let mut data = if skip {
        defaults.clone()
    } else {
        let outfile = Some(install_folder.join(PathBuf::from("sensitive.nix")));
        let template = dots_location.join(PathBuf::from("nix/spoof/flake.nix"));
        template::config_template_with_defaults(template, defaults.clone(), outfile)?
    };

    // template install flake
    let outfile = Some(install_folder.join(PathBuf::from("install.nix")));
    let template = dots_location.join(PathBuf::from("nix/spoof/install.nix"));
    let other_data = template::config_template_with_defaults(template, defaults, outfile)?;
    // merge data
    utils::merge(&mut data, other_data);

    // system_add config
    let outfile = Some(install_folder.join(PathBuf::from("flake.nix")));
    let flake = dots_location.join(PathBuf::from("flake.nix"));
    let mut system = parse_system(flake)?;
    let config = Config::maybe_new_from_data(&data)?;
    let _ = system.add_config(config)?;
    utils::maybe_write(outfile, system.render()?)?;

    // template the machine config
    let outfile = Some(install_folder.join(PathBuf::from("machine.nix")));
    let template = dots_location.join(PathBuf::from("nix/spoof/machine.nix"));
    let result = template::apply_nix_template(&data, read_to_string(template)?);
    utils::maybe_write(outfile, result?)?;

    // template the shell script
    let outfile = Some(install_folder.join(PathBuf::from("provision.sh")));
    let template = dots_location.join(PathBuf::from("nix/spoof/provision.sh"));
    let result = template::apply_template(&data, read_to_string(template)?);
    utils::maybe_write(outfile, result?)?;

    Ok(())
}
