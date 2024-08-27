use std::convert::TryInto;

use pgp::crypto::sym::SymmetricKeyAlgorithm;
use pgp::types::StringToKey;
use sha_crypt::{sha512_check, sha512_simple, Sha512Params};

use rand::thread_rng;

use regex::Regex;

use handlebars::JsonValue;
use requestty::{Answer, Choice, DefaultSeparator, OnEsc, Question};

use crate::commands::template::apply_template;

pub fn prompts(key: String, context: &JsonValue) -> Option<String> {
    match key.as_str() {
        "certificates" => Some("".to_string()),
        "default_wm" => default_wm(),
        "sshd_port" => number("Provide the accepting port number".to_string()),
        "git_email" => free("Enter your email for git".to_string()),
        "git_name" => free("Enter your name for git".to_string()),
        "git_signing_key" => hex("Enter your gpg key fingerprint".to_string(), 16),
        "hashed" => password("system password".to_string(), true),
        "keybase_paper" => paper(),
        "keybase_username" => user("Enter your keybase username (https://keybase.io/)".to_string()),
        "networking" => networking(),
        "pkgs" => pkgs(),
        "user" => user("Enter your username".to_string()),
        // context dependent
        "dots" => context["user"]
            .as_str()
            .map(|u| format!("/home/{}/.dots", u)),
        "sellout" => Some("".to_string()),
        "unfree" => Some("".to_string()),
        "insecure" => Some("".to_string()),
        "getty" => getty_qr(
            context["user"].as_str().map(|x| x.to_string()),
            context["git_email"].as_str().map(|x| x.to_string()),
        ),

        // install
        "installation_hostname" => user("Enter system hostname".to_string()),
        "installation_hostid" => hex(
            "Enter a 8 byte (hex) hostid, see gist.github.com/a8962d61a54631cd72cff16d3292cc69 for ideas"
                .to_string(),
            8,
        ),
        "installation_description" => free("Enter system description".to_string()),
        "installation_category" => Some("machines".to_string()),

        // disko


        // zfs legacy
        "installation_zfs_enabled" => {
            if context["installation_disko_enabled"].as_bool().unwrap_or(false) {
                Some("false".to_string())
            } else{
                confirm("Install with legacy zfs?".to_string())
            }},
        "installation_zfs_encrypted" => confirm("Encrypt partitions?".to_string()),
        "installation_zfs_pool" => {
            user("What should we name your zfs pool? (e.g. zoot)".to_string())
        }
        "installation_zfs_disks" => select_disks(context["installation_zfs_available"].clone()),
        "installation_zfs_bootable" => choose_disk(context["installation_zfs_available"].clone()),
        _ => None,
    }
}

fn regex_prompt(prompt: String, error: String, re: Regex) -> Option<String> {
    requestty::prompt_one(
        Question::input("regexed")
            .message(prompt)
            .validate(|u, _| match re.is_match(u) {
                true => Ok(()),
                false => Err(error.clone()),
            })
            .build(),
    )
    .ok()
    .and_then(|u| u.as_string().map(|u| u.trim().to_string()))
}

fn free(prompt: String) -> Option<String> {
    let re = Regex::new(r"^.{0, 512}$").unwrap();
    regex_prompt(prompt, "String too long".to_string(), re)
}

fn user(prompt: String) -> Option<String> {
    let re = Regex::new(r"^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$").unwrap();
    regex_prompt(prompt, "Username is not POSIX compliant".to_string(), re)
}

fn number(prompt: String) -> Option<String> {
    let re = Regex::new(r"^[0-9]+$").unwrap();
    regex_prompt(prompt, "Not a valid number".to_string(), re)
}

fn hex(prompt: String, length: u32) -> Option<String> {
    let re = Regex::new(&format!(r"^[A-Fa-f0-9]{{{}}}$", length)).unwrap();
    regex_prompt(
        prompt,
        format!("Not valid hex (expected length {})", length),
        re,
    )
}

fn confirm(prompt: String) -> Option<String> {
    requestty::prompt_one(Question::confirm("confirm").message(prompt).build())
        .ok()
        .and_then(|u| u.as_bool().map(|u| if u { "true" } else { "false" }.to_string()))
}

fn password(prompt: String, hashed: bool) -> Option<String> {
    loop {
        if let Some(pass) = requestty::prompt_one(
            Question::password("password")
                .message("Enter ".to_owned() + &prompt)
                .filter(|m, _| match sha512_simple(&m, &Sha512Params::default()) {
                    Ok(s) => s,
                    Err(_) => "".to_string(),
                })
                .mask('*')
                .build(),
        )
        .ok()?
        .as_string()
        {
            if let Ok(answer) = requestty::prompt_one(
                Question::password("password")
                    .message("Confirm ".to_owned() + &prompt)
                    .on_esc(OnEsc::Terminate)
                    .mask('*')
                    .validate(|m, _| match sha512_check(m, pass) {
                        Ok(_) => Ok(()),
                        Err(_) => Err("Passwords do not match (press ESC to reset)".to_string()),
                    })
                    .build(),
            ) {
                if hashed {
                    return Some(pass.to_string());
                } else {
                    return answer.as_string().map(|p| p.to_string());
                }
            }
        }
    }
}

fn paper() -> Option<String> {
    let re = Regex::new(r"^\s*([a-z]+\s+){12}[a-z]+\s*$").unwrap();
    let paper_key = regex_prompt(
        "Enter your keybase paper key".to_string(),
        "keybase paperkeys are 13 lowercase words".to_string(),
        re,
    );
    if let Ok(Answer::Bool(true)) = requestty::prompt_one(
        Question::confirm("enable")
            .message("Store encrypted?")
            .default(true)
            .build(),
    ) {
        let mut rng = thread_rng();
        let s2k = StringToKey::new_default(&mut rng);
        pgp::composed::message::Message::new_literal_bytes("paper.key", paper_key?.as_bytes())
            .encrypt_with_password(&mut rng, s2k, SymmetricKeyAlgorithm::Twofish, || {
                password("pgp encrypting password".to_string(), false)
                    .unwrap_or_else(|| "".to_string())
            })
            .ok()?
            .to_armored_bytes(None)
            .ok()
            .map(String::from_utf8)?
            .ok()
    } else {
        paper_key
    }
}

fn default_wm() -> Option<String> {
    requestty::prompt_one(
        Question::select("wm")
            .message("Which window manager do you want?")
            .choices(vec![
                "hyprland".into(),
                "i3".into(),
                "sway".into(),
                "xmonad".into(),
                DefaultSeparator,
                "frame buffer".into(),
                "none".into(),
            ])
            .build(),
    )
    .ok()?
    .as_list_item()
    .map(|x| match x.text.as_str() {
        "frame buffer" => "fb".to_string(),
        s => s.to_string(),
    })
}

fn networking() -> Option<String> {
    nix_block(
        "Specify network configuration".into(),
        r#"{
    wireless = {
        enable = true;
        userControlled.enable = true;
        interfaces = [ "wlp4s0" ];
        networks = {
            "my_ssid" = {
                "psk" = "my passphrase";
            };
        };
    };
}"#
        .into(),
    )
}

fn nix_block(message: String, block: String) -> Option<String> {
    requestty::prompt_one(
        Question::editor("block")
            .message(message)
            .extension(".nix")
            .validate(|data, _| {
                let ast = rnix::parse(data);
                let mut errors = "".to_string();
                for error in ast.errors() {
                    errors.push_str(&format!("error: {}\n", error));
                }
                if errors.is_empty() {
                    return Ok(());
                }
                Err(errors)
            })
            .default(block)
            .build(),
    )
    .ok()
    .and_then(|u| u.as_string().map(|u| u.to_string()))
}

fn format_disk_strings(disks: &serde_json::Value) -> Vec<String> {
    disks
        .as_array()
        .map(|x| {
            x.iter()
                .map(|xp| {
                    apply_template(xp, "{{name}} ➔ {{model}} ({{size}})".to_string())
                        .unwrap_or_else(|_| "".to_string())
                })
                .collect()
        })
        .unwrap_or_else(|| [].to_vec())
}

fn select_disks(disks: serde_json::Value) -> Option<String> {
    requestty::prompt_one(
        Question::multi_select("disks")
            .message("Select disks for zfs pool.")
            .choices(format_disk_strings(&disks))
            .build(),
    )
    .ok()?
    .as_list_items()
    .map(|x| {
        x.iter()
            .map(|x| format!("/dev/{}", disks[x.index]["name"].as_str().unwrap_or("")))
            .collect::<Vec<String>>()
            .join("\" \"")
    })
}

fn choose_disk(disks: serde_json::Value) -> Option<String> {
    requestty::prompt_one(
        Question::select("disks")
            .message("Select bootable disk.")
            .choices(format_disk_strings(&disks))
            .build(),
    )
    .ok()?
    .as_list_item()
    .map(|x| format!("/dev/{}", disks[x.index]["name"].as_str().unwrap_or("")))
}

fn pkgs() -> Option<String> {
    requestty::prompt_one(
        Question::multi_select("pkgs")
            .message("Select additional common packages")
            .choices(vec![
                // first one required for type inference
                Choice("zotero".into()),
                "bat".into(),
                "ripgrep".into(),
                "emacs".into(),
            ])
            .build(),
    )
    .ok()?
    .as_list_items()
    .map(|x| {
        format!(
            r#" Packages
            {}"#,
            x.iter()
                .map(|y| y.text.clone())
                .collect::<Vec<String>>()
                .join("\n")
        )
    })
}

fn getty_qr(user: Option<String>, email: Option<String>) -> Option<String> {
    let message = if let Some(email) = email {
        format!("mailto:{}", email)
    } else {
        format!(
            "{}'s nix config. they must be very proud.",
            user.unwrap_or_else(|| "".to_string())
        )
    };
    // Add getty
    let extra_info = vec![
        "Linux \\r (\\m)",
        "nixpkgs/${pkgs_rev}",
        "dots/${dots_rev}",
        "\\d",
    ];
    let qr_code = qr_code::QrCode::new(message).unwrap();
    let offset: usize = 1;
    Some(
        qr_code
            .to_string(false, offset.try_into().unwrap())
            .lines()
            .enumerate()
            .map(move |(i, x)| {
                if i >= offset && i < extra_info.len() + offset {
                    format!("{} {}", x, extra_info[i - offset])
                } else {
                    x.trim_end().to_string()
                }
            })
            .collect::<Vec<_>>()
            .join("\n"),
    )
}
