use std::error::Error;
use std::fs::{read_to_string, File};
use std::io::Write;

use std::path::PathBuf;

use nixpkgs_fmt::reformat_string;
use rnix::types::*;
use rnix::AST;

use requestty::{Answer, Question};

use handlebars::Handlebars;
use handlebars::JsonValue;
use serde_json::json;

use crate::parse::*;
use crate::prompts::prompts;

// TODO: Just make this part of prompts.
use crate::prompts::getty_qr;

fn build_questions(prefix: String, lib: AttrSet) -> Result<JsonValue, Box<dyn Error>> {
    let mut data = json!({});
    for entry in lib.entries() {
        let key = maybe_key(&entry).ok_or("Could not extract key. Invalid Nix?")?;
        if key == "enable" {
            continue;
        }
        let key = format!("{}{}", prefix, key);
        if let Some(body) = maybe_body(&entry) {
            if let Some(enable_node) = find_entry("enable", body.clone()) {
                if let Some(enable_value) = rnix::types::Value::cast(enable_node) {
                    match enable_value.to_value() {
                        Ok(rnix::value::Value::Boolean(boolean)) => {
                            if let Ok(Answer::Bool(true)) = requestty::prompt_one(
                                Question::confirm("enable")
                                    .message(&format!("Enable {}?", key))
                                    .default(boolean)
                                    .build(),
                            ) {
                                let prefix = key.clone() + "_";
                                data[key] = json!(true);
                                for (key, value) in
                                    build_questions(prefix, body)?.as_object().unwrap()
                                {
                                    data[key] = json!(value);
                                }
                            }
                        }
                        Ok(x) => {
                            println!("{:?}", x);
                            return Err("Enable value is not a boolean".into());
                        }
                        _ => {}
                    }
                }
                continue;
            }
        }
        let maybe_json = prompts(key.clone()).ok_or(format!("Unmanaged entry: {}", &key))?;
        data[key] = json!(maybe_json);
    }
    Ok(data)
}
fn build_questions_from_root(ast: &AST) -> Result<JsonValue, Box<dyn Error>> {
    let partial_find = |key| move |set| find_entry(key, set);
    let lib = ast
        .root()
        .inner()
        .and_then(AttrSet::cast)
        .ok_or("Malformed flake template root isn't a set")
        .ok()
        .and_then(partial_find("outputs"))
        .and_then(Lambda::cast)
        .ok_or("Malformed flake template (missing output)")
        .ok()
        .and_then(|x| x.body())
        .ok_or("Malformed flake template (invalid output)")
        .ok()
        .and_then(AttrSet::cast)
        .ok_or("Malformed flake template (output missing body)")
        .ok()
        .and_then(partial_find("lib"))
        .and_then(AttrSet::cast)
        .ok_or("Malformed flake template (missing lib)")?;
    build_questions("".to_string(), lib)
}

pub fn apply_template(
    data: JsonValue,
    content: String,
) -> Result<String, Box<dyn Error>> {
    let mut reg = Handlebars::new();
    reg.register_template_string("flake", content)?;
    let attempt = reg.render("flake", &data)?;
    let ast = rnix::parse(&attempt);
    for error in ast.errors() {
        eprintln!("error: {}", error);
    }
    if !ast.errors().is_empty() {
        eprintln!("potential issues: {}", nixpkgs_fmt::explain(&attempt));
        return Err(
            "Could not parse template. Please open an issue?! github:dmadisetti/.dots/issues"
                .into(),
        );
    }
    Ok(reformat_string(&attempt))
}

pub fn config_template(file: PathBuf, outfile: Option<PathBuf>) -> Result<(), Box<dyn Error>> {
    let content = match read_to_string(file) {
        Ok(content) => content,
        Err(err) => {
            eprintln!("error reading file: {}", err);
            return Ok(());
        }
    };
    let ast = rnix::parse(&content);
    for error in ast.errors() {
        println!("error: {}", error);
    }
    if !ast.errors().is_empty() {
        println!("potential issues: {}", nixpkgs_fmt::explain(&content));
        return Err("Please fix template errors.".into());
    }

    // Refresh content to get rid of extrenous comments.
    let content = ast.root().inner().unwrap().to_string();
    let mut data = build_questions_from_root(&ast)?;

    data["misc"] = json!(format!(
        r#"
    getty = pkgs_rev: dots_rev: ''
{}
    '';"#,
        getty_qr(
            data["user"].as_str().map(|x| x.to_string()),
            data["git_email"].as_str().map(|x| x.to_string())
        )
        .or_else(|| Some("".to_string()))
        .unwrap()
    ));

    let attempt = apply_template(data, content)?;
    match outfile {
        Some(outfile) => {
            let mut file = File::create(outfile)?;
            file.write_all(attempt.as_bytes())?;
        }
        None => println!("{}", attempt),
    };
    Ok(())
}