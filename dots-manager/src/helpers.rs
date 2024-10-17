use handlebars::{
    BlockParamHolder, Context, Handlebars, Helper, JsonValue, Output, RenderContext, RenderError,
    RenderErrorReason,
};
use serde_json::{json, Value};

// a custom block helper to bind a variable name to a value
pub fn helper<'reg, 'rc>(
    h: &Helper<'rc>,
    _r: &'reg Handlebars<'reg>,
    ctx: &'rc Context,
    rc: &mut RenderContext<'reg, 'rc>,
    _out: &mut dyn Output,
) -> Result<(), RenderError> {
    let param = h
        .param(0)
        .ok_or_else(|| RenderErrorReason::ParamNotFoundForIndex("hook", 0))?;

    let Some(Value::String(name)) = param.try_get_constant_value() else {
        return Err(RenderErrorReason::ParamTypeMismatchForName(
            "hook",
            "0".to_string(),
            "constant string".to_string(),
        )
        .into());
    };

    let value = match name.as_str() {
        "installation_devices" => {
            // Loop over disks to create zfs entries
            // Need keys: name, disk, boot
            // Should be installation_zfs_cache + installation_zfs_bootable + installation_zfs_disks
            // deduped
            let cache = match &ctx.data()["installation_zfs_cache"] {
                JsonValue::String(v) => v,
                _ => {
                    return Err(RenderErrorReason::MissingVariable(Some(
                        "installation_zfs_cache".to_string(),
                    ))
                    .into());
                }
            };
            let bootable = match &ctx.data()["installation_zfs_bootable"] {
                JsonValue::String(v) => v,
                _ => {
                    return Err(RenderErrorReason::MissingVariable(Some(
                        "installation_zfs_bootable".to_string(),
                    ))
                    .into());
                }
            };
            let home = match &ctx.data()["installation_disko_home"] {
                JsonValue::String(v) => v,
                _ => {
                    return Err(RenderErrorReason::MissingVariable(Some(
                        "installation_disko_home".to_string(),
                    ))
                    .into());
                }
            };

            let mut all_devices = vec![cache.clone(), bootable.clone()];
            let disks = match &ctx.data()["installation_zfs_disks"] {
                JsonValue::String(v) => v,
                _ => {
                    return Err(RenderErrorReason::MissingVariable(Some(
                        "installation_zfs_disks".to_string(),
                    ))
                    .into());
                }
            };
            let mut disks = disks
                .split("\" \"")
                .map(|s| s.to_string())
                .collect::<Vec<String>>();
            all_devices.append(&mut disks);
            all_devices.dedup();

            let mut devices = vec![];
            let mut index = 0;
            for device in all_devices {
                if device == *home {
                    return Err(RenderErrorReason::Other(format!(
                        "Disk {} cannot be used for home and zfs.",
                        device
                    ))
                    .into());
                }
                let boot = device == *bootable;
                let cached = device == *cache;
                // e.g. zfs0 zfs1c zfs7b zfs8bc
                let disk_name = {
                    let mut n = format!("zfs{}", index);
                    if boot {
                        n.push('b');
                    }
                    if cached {
                        n.push('c');
                    }
                    n
                };
                let device = json!({
                    "name": disk_name,
                    "disk": device,
                    "boot": boot,
                });
                devices.push(device);
                index += 1;
            }
            json!(devices)
        }
        _ => {
            return Err(RenderErrorReason::HelperNotFound("Unknown hook".to_string()).into());
        }
    };

    let block = rc.block_mut().unwrap();
    block.set_block_param(name, BlockParamHolder::Value(value));

    Ok(())
}
