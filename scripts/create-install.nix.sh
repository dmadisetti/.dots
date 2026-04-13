#!/usr/bin/env bash
ensure_dotfiles

tmp_install_dir=$(mktemp -d -t dots-install-XXXXXXXXXX)

echo -en "$WELCOME"
dots-manager pre-installation "$DOTFILES" "$tmp_install_dir" \
   <(echo -n "{\"dots\": \"$DOTFILES\", \
             $(infer_settings)}") || exit 1

cat <<EOF > "$tmp_install_dir/continue-install.sh"
#!/usr/bin/env bash

tmp_install_dir=$tmp_install_dir
source "$tmp_install_dir/provision.sh"
source "$DOTFILES/scripts/run-install.nix.sh"
echo 'You can reboot now (:'
EOF
chmod +x "$tmp_install_dir/continue-install.sh"

source "$tmp_install_dir/provision.sh"
