use rnix::types::*;
use rnix::{SyntaxNode};

pub fn maybe_body(entry: &rnix::types::KeyValue) -> Option<AttrSet> {
    if let Some(set) = AttrSet::cast(entry.value()?) {
        return Some(set);
    }
    None
}

pub fn maybe_key(entry: &rnix::types::KeyValue) -> Option<String> {
    if let Some(attr) = entry.key() {
        let ident = attr.path().last().and_then(Ident::cast);
        return ident.as_ref().map(Ident::as_str).map(|s| s.to_string());
    }
    None
}

pub fn find_entry(key: &str, set: AttrSet) -> Option<SyntaxNode> {
    for entry in set.entries() {
        let value = entry.value();
        if let Some(look) = maybe_key(&entry) {
            if look == key {
                return value;
            }
        }
    }
    None
}

