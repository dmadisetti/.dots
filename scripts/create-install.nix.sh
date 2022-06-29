#!/usr/bin/env bash
ensure_dotfiles

tmp_install_dir=$(mktemp -d -t dots-install-XXXXXXXXXX)

echo -en "$WELCOME"
dots-manager pre-installation "$DOTFILES" "$tmp_install_dir" \
   <(echo -n "{\"dots\": \"$DOTFILES\", \
             $(infer_settings)}") || exit 1

source "$tmp_install_dir/provision.sh"
