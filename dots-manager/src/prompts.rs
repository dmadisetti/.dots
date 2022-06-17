use std::convert::TryInto;

use pgp::crypto::sym::SymmetricKeyAlgorithm;
use pgp::types::StringToKey;
use sha_crypt::{sha512_check, sha512_simple, Sha512Params};

use rand::thread_rng;

use regex::Regex;

use handlebars::JsonValue;
use requestty::{Answer, Choice, DefaultSeparator, OnEsc, Question};

pub fn prompts(key: String, context: &JsonValue) -> Option<String> {
    match key.as_str() {
        "certificates" => Some("".to_string()),
        "default_wm" => default_wm(),
        "sshd_port" => free("Provide the accepting port number".to_string()),
        "git_email" => free("Enter your email for git".to_string()),
        "git_name" => free("Enter your name for git".to_string()),
        "git_signing_key" => free("Enter your gpg key fingerprint".to_string()),
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
        "getty" => getty_qr(
            context["user"].as_str().map(|x| x.to_string()),
            context["git_email"].as_str().map(|x| x.to_string()),
        ),
        "installation_hostname" => user("Enter system hostname".to_string()),
        "installation_hostid" => Some("".to_string()),
        "installation_description" => free("Enter system description".to_string()),
        "installation_category" => Some("machines".to_string()),
        "installation_zfs_pool" => Some("".to_string()),
        _ => None,
    }
}

fn free(prompt: String) -> Option<String> {
    requestty::prompt_one(Question::input("free").message(prompt).build())
        .ok()
        .and_then(|u| u.as_string().map(|u| u.to_string()))
}

fn user(prompt: String) -> Option<String> {
    let re = Regex::new(r"^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$").unwrap();
    requestty::prompt_one(
        Question::input("user")
            .message(prompt)
            .validate(|u, _| match re.is_match(u) {
                true => Ok(()),
                false => Err("Username is not POSIX compliant".to_string()),
            })
            .build(),
    )
    .ok()
    .and_then(|u| u.as_string().map(|u| u.to_string()))
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
    let paper_key = requestty::prompt_one(
        Question::editor("paper")
            .message("Enter your keybase paper key:")
            .validate(|u, _| match re.is_match(u) {
                true => Ok(()),
                false => Err("keybase paperkeys are 13 lowercase words".to_string()),
            })
            .build(),
    )
    .ok()
    .and_then(|u| u.as_string().map(|u| u.trim().to_string()));
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
