use std::error::Error;
use std::fs::read_to_string;

use std::collections::HashMap;
use std::path::PathBuf;

use rnix::types::*;
use rnix::TextRange;

use serde_json::json;

use crate::parse::find_entry;
use crate::parse::maybe_key;
use serde::{Deserialize, Serialize};

use crate::commands::template::apply_nix_template;

use handlebars::JsonValue;

const MAST: &str = "#           ▜███▙       ▜███▙  ▟███▛
#            ▜███▙       ▜███▙▟███▛
#             ▜███▙       ▜██████▛
#      ▟█████████████████▙ ▜████▛     ▟▙
#     ▟███████████████████▙ ▜███▙    ▟██▙
#            ▄▄▄▄▖           ▜███▙  ▟███▛
#           ▟███▛             ▜██▛ ▟███▛
#          ▟███▛               ▜▛ ▟███▛
# ▟███████████▛                  ▟██████████▙
# ▜██████████▛                  ▟███████████▛
#       ▟███▛ ▟▙               ▟███▛
#      ▟███▛ ▟██▙             ▟███▛
#     ▟███▛  ▜███▙           ▝▀▀▀▀
#     ▜██▛    ▜███▙ ▜██████████████████▛
#      ▜▛     ▟████▙ ▜████████████████▛
#            ▟██████▙       ▜███▙
#           ▟███▛▜███▙       ▜███▙
#          ▟███▛  ▜███▙       ▜███▙
#          ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘
#";

#[derive(Debug)]
pub struct System {
    configs: HashMap<String, Config>,
    template_header: String,
    template_footer: String,
}

#[derive(Debug, Deserialize, Serialize)]
struct Category {
    name: String,
    machines: Vec<Config>,
}

impl Category {
    fn new(name: String, machines: Vec<Config>) -> Self {
        Category { name, machines }
    }

    fn add_machine(&mut self, machine: Config) {
        self.machines.push(machine);
    }

    fn sorted(&self) -> Category {
        let mut machines = self.machines.clone();
        machines.sort_by(|a, b| a.machine.cmp(&b.machine));
        Category {
            name: self.name.clone(),
            machines,
        }
    }
}

impl System {
    fn new(
        configs: HashMap<String, Config>,
        template_header: String,
        template_footer: String,
    ) -> Self {
        System {
            configs,
            template_header,
            template_footer,
        }
    }

    pub fn render(&self) -> Result<String, Box<dyn Error>> {
        let mut configs = self.configs.values().collect::<Vec<_>>();
        let mut categories = HashMap::<String, Category>::new();
        for config in configs.clone() {
            if categories.contains_key(&config.category) {
                categories
                    .get_mut(&config.category)
                    .ok_or("")?
                    .add_machine(config.clone());
            } else {
                categories.insert(
                    config.category.clone(),
                    Category::new(config.category.clone(), vec![config.clone()]),
                );
            }
        }
        let mut categories = categories
            .values()
            .collect::<Vec<_>>()
            .iter()
            .map(|category| category.sorted())
            .collect::<Vec<_>>();
        categories.sort_by(|a, b| a.name.cmp(&b.name));
        let categories = categories;

        configs.sort_by(|a, b| a.machine.cmp(&b.machine));
        let configs = configs.iter().map(|c| json!(&c)).collect::<Vec<_>>();

        let data = json!({
            "mast": MAST,
            "categories": categories,
            "configs": configs,
            "template_header": self.template_header,
            "template_footer": self.template_footer,
        });
        let content = "{{mast}}
        {{# each categories as |category| }}
        # » Implemented {{category.name}}:
            {{# each category.machines as |config| }}
        #    • {{config.machine}} → {{{config.description}}}
            {{/ each }}
        #
        {{/each}}
        # A fair bit of inspiration from github:srid/nixos-config
        {{{template_header}}}
        { {{#each configs as | config |}}
        {{{config.machine}}} = {{{config.config}}};
        {{/each}} }{{{template_footer}}}"
            .to_string();
        apply_nix_template(&data, content)
    }

    pub fn list_configs(&self) -> Vec<String> {
        self.configs.keys().cloned().collect()
    }

    pub fn remove_config(&mut self, name: &str) {
        self.configs.remove(name);
    }

    pub fn add_config(&mut self, config: Config) -> Result<(), Box<dyn Error>> {
        self.configs.insert(config.machine.clone(), config);
        Ok(())
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Config {
    machine: String,
    config: String,
    description: String,
    category: String,
}

impl Config {
    fn new(machine: String, config: String, description: String, category: String) -> Self {
        Self {
            machine,
            config,
            description,
            category,
        }
    }

    fn new_partial(machine: String, description: String, category: String) -> Self {
        Self {
            machine,
            config: "".to_string(),
            description,
            category,
        }
    }

    pub fn maybe_new_from_data(data: &JsonValue) -> Result<Self, Box<dyn Error>> {
        let machine = data
            .get("installation_hostname")
            .ok_or("Bad hostname")?
            .as_str()
            .ok_or("Bad hostname")?
            .to_string();
        let description = data
            .get("installation_description")
            .ok_or("Bad description")?
            .as_str()
            .ok_or("Bad description")?
            .to_string();
        let category = data
            .get("installation_category")
            .ok_or("Bad category")?
            .as_str()
            .ok_or("Bad category")?
            .to_string();
        let content = "utils.mkComputer {
          machineConfig = ./nix/machines/{{installation_hostname}}.nix;
          wm = \"{{default_wm}}\";
          userConfigs = [ ];
        }"
        .to_string();
        let config = apply_nix_template(data, content)?.trim().to_string();
        Ok(Self {
            machine,
            config,
            description,
            category,
        })
    }

    fn merge(&self, config: String) -> Self {
        Self {
            machine: self.machine.clone(),
            config,
            description: self.description.clone(),
            category: self.category.clone(),
        }
    }
}

pub fn parse_system(file: PathBuf) -> Result<System, Box<dyn Error>> {
    let content = match read_to_string(file) {
        Ok(content) => content,
        Err(err) => {
            eprintln!("error reading file: {}", err);
            return Err(Box::new(err));
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
    let partial_find = |key| move |set| find_entry(key, set);
    let maybe_root = ast
        .root()
        .inner()
        .and_then(AttrSet::cast)
        .ok_or("Malformed flake template root isn't a set");

    // lol, this is so brittle. need nicer way
    // maybe special syntax: .outputs\_2.{0}.nixosConfigurations
    // think I need macros cause will be type nightmare... not worth
    let lib = maybe_root
        .clone()
        .ok()
        .and_then(partial_find("outputs"))
        .and_then(Lambda::cast)
        .ok_or("Malformed flake template (missing output)")?;
    let lib = lib
        .body()
        .ok_or("Malformed flake template (invalid output)")?;
    let lib = LetIn::cast(lib).ok_or("Malformed flake template (expected let-in output)")?;
    let lib = lib
        .body()
        .ok_or("Malformed flake template (invalid output)")?;
    let lib = BinOp::cast(lib).ok_or("Malformed flake template (expected overloaded body)")?;
    let lib = lib
        .lhs()
        .ok_or("Malformed flake template (could not isolate main body)")?;
    let lib =
        AttrSet::cast(lib).ok_or("Malformed flake template (output body is not attribute set)")?;
    let lib = partial_find("nixosConfigurations")(lib)
        .and_then(AttrSet::cast)
        .ok_or("Malformed flake template (missing nixosConfigurations)")?;

    let root = maybe_root?;
    let bounds = root.node().text_range();
    let range = lib.node().text_range();

    let mut category = "config".to_string();

    let mut configs = HashMap::<String, Config>::new();
    for line in content
        .lines()
        .filter(|x| x.contains('•') || x.contains('»'))
    {
        if line.contains('»') {
            category = line
                .split('»')
                .nth(1)
                .unwrap()
                .replace(':', "")
                .replace("Implemented", "")
                .trim()
                .to_string();
            continue;
        }
        // else "#    • "
        let mut parts = line.split('→');
        let key = parts
            .next()
            .unwrap()
            .replace('•', "")
            .replace('#', "")
            .trim()
            .to_string();
        let value = parts.next().unwrap().trim().to_string();
        let config = Config::new_partial(key.clone(), value, category.clone());
        configs.insert(key, config);
    }

    for entry in lib.entries() {
        let key = maybe_key(&entry).ok_or("Could not extract key. Invalid Nix?")?;
        let value = entry.value().unwrap().to_string();
        if configs.contains_key(&key) {
            let config = {
                let config = configs.get_mut(&key).unwrap();
                config.merge(value)
            };
            configs.insert(key, config);
        } else {
            let config = Config::new(
                key.clone(),
                value,
                "todo: description".to_string(),
                "".to_string(),
            );
            configs.insert(key, config);
        }
    }

    // build and sammich
    Ok(System::new(
        configs,
        (&content[TextRange::new(bounds.start(), range.start())]).to_string(),
        (&content[TextRange::new(range.end(), bounds.end())]).to_string(),
    ))
}
