#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
install_packages=false
case "${1:-}" in
  --packages) install_packages=true ;;
  '') ;;
  *) printf 'Uso: %s [--packages]\n' "$0" >&2; exit 2 ;;
esac
if (( EUID == 0 )); then
  echo 'Execute como seu usuário, sem sudo. --packages usa sudo apenas para o apt.' >&2
  exit 1
fi
if "$install_packages"; then
  sudo apt update
  sudo apt install bash bash-completion git python3 neovim tmux fortune-mod xclip wl-clipboard ripgrep
fi
for tool in bash git python3 nvim tmux; do
  if ! command -v "$tool" >/dev/null; then
    printf 'Dependência ausente: %s. Execute novamente com --packages.\n' "$tool" >&2
    exit 1
  fi
done
strfile_cmd=$(command -v strfile || true)
if [[ -z "$strfile_cmd" && -x /usr/sbin/strfile ]]; then
  strfile_cmd=/usr/sbin/strfile
fi
if [[ -z "$strfile_cmd" ]]; then
  echo 'strfile ausente. Execute novamente com --packages.' >&2
  exit 1
fi
bash -n "$repo_dir/.config/bash/terminal.bash"
backup_dir=$(mktemp -d "$data_dir/configs-backup.XXXXXXXX" 2>/dev/null || {
  mkdir -p "$data_dir"
  mktemp -d "$data_dir/configs-backup.XXXXXXXX"
})
install_file() {
  local source=$1 target=$2
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_dir$(dirname -- "$target")"
    cp -a -- "$target" "$backup_dir$target"
  fi
  mkdir -p -- "$(dirname -- "$target")"
  # Remove symlinks rather than writing through them.
  rm -f -- "$target"
  cp -- "$source" "$target"
  printf '%s\n' "$target" >> "$backup_dir/installed-files.txt"
}
install_file "$repo_dir/.config/bash/terminal.bash" "$config_dir/bash/terminal.bash"
# Preserve existing Bash setup, append one idempotent loader.
bashrc_temp=$(mktemp)
if [[ -f "$HOME/.bashrc" ]]; then
  cat -- "$HOME/.bashrc" > "$bashrc_temp"
fi
if ! grep -qF '# configs: Bash terminal customization' "$bashrc_temp"; then
  cat >> "$bashrc_temp" <<'BASHRC'

# configs: Bash terminal customization
if [[ $- == *i* && -f ${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash ]]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash"
fi
BASHRC
fi
install_file "$bashrc_temp" "$HOME/.bashrc"
rm -f -- "$bashrc_temp"
install_file "$repo_dir/.config/nvim/init.vim" "$config_dir/nvim/init.vim"
install_file "$repo_dir/.config/tmux/tmux-gruvbox-dark.conf" "$config_dir/tmux/tmux-gruvbox-dark.conf"
# tmux reads ~/.tmux.conf; write the actual XDG theme path there.
tmux_config=$(mktemp)
trap 'rm -f -- "$tmux_config"' EXIT
python3 - "$repo_dir/.tmux.conf" "$config_dir" "$tmux_config" <<'PY'
import sys
from pathlib import Path
path = str(Path(sys.argv[2]) / 'tmux/tmux-gruvbox-dark.conf')
quoted = '"' + path.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$') + '"'
s = Path(sys.argv[1]).read_text().replace('source-file "~/.config/tmux/tmux-gruvbox-dark.conf"', 'source-file ' + quoted)
Path(sys.argv[3]).write_text(s)
PY
install_file "$tmux_config" "$HOME/.tmux.conf"
install_file "$repo_dir/fraserfortune" "$data_dir/fortunes/frasesfortune"
if [[ -e "$data_dir/fortunes/frasesfortune.dat" || -L "$data_dir/fortunes/frasesfortune.dat" ]]; then
  mkdir -p "$backup_dir$data_dir/fortunes"
  cp -a "$data_dir/fortunes/frasesfortune.dat" "$backup_dir$data_dir/fortunes/"
fi
rm -f -- "$data_dir/fortunes/frasesfortune.dat"
"$strfile_cmd" "$data_dir/fortunes/frasesfortune" "$data_dir/fortunes/frasesfortune.dat"
printf '%s\n' "$data_dir/fortunes/frasesfortune.dat" >> "$backup_dir/installed-files.txt"
printf 'Instalado. Backup: %s\nAbra um novo terminal Bash.\nSeu .bashrc foi preservado com um bloco adicional; shell padrão inalterado.\n' "$backup_dir"
