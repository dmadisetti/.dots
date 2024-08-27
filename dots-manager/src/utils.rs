use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

use serde_json::Value;

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

pub fn merge(a: &mut Value, b: Value) {
    match (a, b) {
        (a @ &mut Value::Object(_), Value::Object(b)) => {
            let a = a.as_object_mut().unwrap();
            for (k, v) in b {
                merge(a.entry(k).or_insert(Value::Null), v);
            }
        }
        (a, b) => *a = b,
    }
}

enum DiskType {
    SCSI,
    NVME,
}

fn lsblk_(disk_type: DiskType) -> Result<Vec<serde_json::Value>, Box<dyn Error>> {
    let disk_arg = match disk_type {
        DiskType::SCSI => "-JSo",
        DiskType::NVME => "-JNo",
    };
    let output = std::process::Command::new("lsblk")
        .arg(disk_arg)
        .arg("name,model,size")
        .output()
        .expect("failed to execute process");
    Ok(
        serde_json::from_str::<serde_json::Value>(std::str::from_utf8(&output.stdout)?)?
            ["blockdevices"]
            .as_array()
            .unwrap()
            .clone(),
    )
}

pub fn lsblk() -> Result<serde_json::Value, Box<dyn Error>> {
    let mut disks = lsblk_(DiskType::SCSI)?;
    let mut nvme_disks = lsblk_(DiskType::NVME)?;
    disks.append(&mut nvme_disks);
    Ok(serde_json::Value::Array(disks))
}
