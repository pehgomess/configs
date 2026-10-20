# Exemplo mínimo. O instalador preserva o .bashrc existente e acrescenta o source.
[[ $- == *i* ]] || return
if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash ]]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash"
fi
