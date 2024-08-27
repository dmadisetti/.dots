use std::error::Error;
use std::fs::read_to_string;

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
use crate::utils::{maybe_write, merge};

fn build_questions(
    defaults: JsonValue,
    prefix: String,
    lib: AttrSet,
) -> Result<JsonValue, Box<dyn Error>> {
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
                            // Backfill if prescribed in defaults
                            let maybe_default = defaults
                                .get(&key)
                                .and_then(|v| v.get("enable"))
                                .and_then(|v| v.as_bool());

                            let maybe_enabled = match maybe_default {
                                Some(value) => value,
                                None => {
                                    // Check to see if a prompt explicitly handles it
                                    match prompts(key.clone(), &data) {
                                        Some(x) => x == "true",
                                        // If not, prompt the user
                                        _ => matches!(
                                            requestty::prompt_one(
                                                Question::confirm("enable")
                                                    .message(&format!(
                                                        "Enable {}?",
                                                        key.replace('_', " ")
                                                    ))
                                                    .default(boolean)
                                                    .build()
                                            ),
                                            Ok(Answer::Bool(true))
                                        ),
                                    }
                                }
                            };
                            if maybe_enabled {
                                let prefix = key.clone() + "_";
                                let inner_default = match defaults.get(key.clone()) {
                                    Some(inner) => inner.clone(),
                                    None => json!({}),
                                };
                                data[key] = json!(true);
                                for (key, value) in build_questions(inner_default, prefix, body)?
                                    .as_object()
                                    .unwrap()
                                {
                                    data[key] = json!(value);
                                }
                            }
                        }
                        Ok(x) => {
                            eprintln!("{:?}", x);
                            return Err("Enable value is not a boolean".into());
                        }
                        _ => {}
                    }
                }
                continue;
            }
        }
        let maybe_json = match defaults.get(&key) {
            Some(x) => x.clone(),
            None => {
                let mut context = data.clone();
                merge(&mut context, defaults.clone());
                let tmp =
                    prompts(key.clone(), &context).ok_or(format!("Unmanaged entry: {}", &key))?;
                json!(tmp)
            }
        };
        data[key] = maybe_json;
    }
    Ok(data)
}
fn build_questions_from_root(ast: &AST, defaults: JsonValue) -> Result<JsonValue, Box<dyn Error>> {
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
    build_questions(defaults, "".to_string(), lib)
}

pub fn apply_template(data: &JsonValue, content: String) -> Result<String, Box<dyn Error>> {
    let mut reg = Handlebars::new();
    reg.register_template_string("dump", content)?;
    Ok(reg.render("dump", &data)?)
}

pub fn apply_nix_template(data: &JsonValue, content: String) -> Result<String, Box<dyn Error>> {
    let mut reg = Handlebars::new();
    reg.register_template_string("flake", content.clone())?;
    let attempt = reg.render("flake", &data)?;
    let ast = rnix::parse(&attempt);

    for error in ast.errors() {
        eprintln!("error: {}", error);
    }
    if !ast.errors().is_empty() {
        eprintln!("potential issues: {}", nixpkgs_fmt::explain(&attempt));
        eprintln!("{}", content);
        return Err(
            "Could not parse template. Please open an issue?! github:dmadisetti/.dots/issues"
                .into(),
        );
    }
    Ok(reformat_string(&attempt))
}

pub fn load_ast(file: PathBuf) -> Result<AST, Box<dyn Error>> {
    let content = match read_to_string(file) {
        Ok(content) => content,
        Err(err) => {
            eprintln!("error reading file: {}", err);
            return Err("Could not read file".into());
        }
    };
    let ast = rnix::parse(&content);
    for error in ast.errors() {
        eprintln!("error: {}", error);
    }
    if !ast.errors().is_empty() {
        eprintln!("potential issues: {}", nixpkgs_fmt::explain(&content));
        return Err("Please fix template errors.".into());
    }
    Ok(ast)
}

pub fn load_defaults(defaults: Option<PathBuf>) -> Result<JsonValue, Box<dyn Error>> {
    match defaults {
        Some(path) => match read_to_string(path) {
            Ok(x) => match serde_json::from_str(&x) {
                Ok(x) => Ok(x),
                Err(e) => {
                    eprintln!("Could not parse defaults: {}", e);
                    Err("Could not parse defaults".into())
                }
            },
            Err(err) => {
                eprintln!("Could not read defaults: {}", err);
                Err("Could not read defaults".into())
            }
        },
        None => Ok(json!({})),
    }
}

pub fn config_template_with_defaults(
    file: PathBuf,
    defaults: JsonValue,
    outfile: Option<PathBuf>,
) -> Result<JsonValue, Box<dyn Error>> {
    let ast = load_ast(file)?;

    // Refresh content to get rid of extrenous comments.
    let data = build_questions_from_root(&ast, defaults)?;

    let content = ast.root().inner().unwrap().to_string();
    let attempt = apply_nix_template(&data, content)?;
    maybe_write(outfile, attempt)?;
    Ok(data)
}

pub fn config_template(
    file: PathBuf,
    defaults: Option<PathBuf>,
    outfile: Option<PathBuf>,
) -> Result<(), Box<dyn Error>> {
    let defaults = load_defaults(defaults)?;
    match config_template_with_defaults(file, defaults, outfile) {
        Err(e) => Err(e),
        Ok(_) => Ok(()),
    }
}
