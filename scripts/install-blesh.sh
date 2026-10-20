#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then
    echo 'Execute como seu usuário, sem sudo.' >&2
    exit 1
fi
for tool in curl tar xz bash; do
    command -v "$tool" >/dev/null || { echo "Dependência ausente: $tool" >&2; exit 1; }
done
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
curl --fail --location --retry 2 --connect-timeout 20 \
    https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
    --output "$work_dir/ble-nightly.tar.xz"
tar -xJf "$work_dir/ble-nightly.tar.xz" -C "$work_dir"
bash -n "$work_dir/ble-nightly/ble.sh"
mkdir -p "$data_dir" "$config_dir/bash"
backup_dir=$(mktemp -d "$data_dir/configs-blesh-backup.XXXXXXXX")
if [[ -e "$data_dir/blesh" ]]; then
    cp -a -- "$data_dir/blesh" "$backup_dir/blesh"
fi
if [[ -e "$config_dir/bash/terminal.bash" ]]; then
    cp -a -- "$config_dir/bash/terminal.bash" "$backup_dir/terminal.bash"
fi
if [[ -e "$HOME/.bashrc" ]]; then
    cp -a -- "$HOME/.bashrc" "$backup_dir/bashrc"
fi
bash "$work_dir/ble-nightly/ble.sh" --install "$data_dir"
# Replace symlinks without writing through them.
rm -f -- "$config_dir/bash/terminal.bash"
cp -- "$repo_dir/.config/bash/terminal.bash" "$config_dir/bash/terminal.bash"
if ! grep -qF '# configs: Bash terminal customization' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC'

# configs: Bash terminal customization
if [[ $- == *i* && -f ${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash ]]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash"
fi
BASHRC
fi
printf 'ble.sh instalado. Backup: %s\nAbra um novo terminal Bash.\n' "$backup_dir"
