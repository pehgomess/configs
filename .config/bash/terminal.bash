# Personalização para Bash interativo; pode ser carregada com source.
[[ $- == *i* ]] || return

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000
shopt -s histappend checkwinsize
command -v nvim >/dev/null && export EDITOR=nvim
export BROWSER=${BROWSER:-xdg-open}
export LESS='-F -X -R'
export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;5;246m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[04;36m'

alias e='nvim'
alias vim='nvim'
alias m='make'
alias g='git'
alias gc='git checkout'
alias vimdiff='nvim -d'
alias c='cargo'
alias ct='cargo test'
alias p='sudo apt'
alias up='sudo apt update && sudo apt upgrade'
if command -v eza >/dev/null; then
    alias ls='eza'
    alias l='eza'
    alias ll='eza -l'
    alias lll='eza -la'
else
    alias ls='ls --color=auto'
    alias l='ls --color=auto'
    alias ll='ls --color=auto -l'
    alias lll='ls --color=auto -la'
fi

__configs_git() {
    command -v git >/dev/null || return 0
    local branch state flags=''
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0
    state=$(git --no-optional-locks status --porcelain --untracked-files=normal 2>/dev/null)
    [[ -n $state ]] && flags='*'
    [[ $state == *'?? '* ]] && flags+='?'
    # Suppress terminal control characters in branch names.
    branch=${branch//[[:cntrl:]]/}
    printf ' (%s%s)' "$branch" "$flags"
}

# Readline needs \[ and \] around colors to wrap long commands correctly.
if [[ ${TERM:-dumb} != dumb ]]; then
    PS1='\[\e[90m\][\A] \[\e[33m\]\u\[\e[0m\]@\[\e[34m\]\h\[\e[90m\]:\[\e[33m\]\W\[\e[32m\]$(__configs_git) \[\e[31m\]| \[\e[0m\]'
else
    PS1='[\A] \u@\h:\W$(__configs_git) | '
fi

__configs_greeting() {
    printf '\nOS: %s\nUptime: %s\nHostname: %s\n' "$(uname -ro)" "$(uptime -p)" "$(hostname)"
    printf '\nDisk usage:\n'
    df -h -l -x tmpfs -x devtmpfs
    if command -v ip >/dev/null; then
        printf '\nNetwork:\n'
        ip -brief address show up
    fi
    local fortune_cmd fortune_dir=${XDG_DATA_HOME:-$HOME/.local/share}/fortunes
    fortune_cmd=$(command -v fortune || true)
    [[ -z $fortune_cmd && -x /usr/games/fortune ]] && fortune_cmd=/usr/games/fortune
    if [[ -n $fortune_cmd && -f $fortune_dir/frasesfortune.dat ]]; then
        printf '\n'
        "$fortune_cmd" "$fortune_dir/frasesfortune"
    fi
}
# One greeting per shell; set CONFIGS_GREETING=0 to disable it.
if [[ ${CONFIGS_GREETING:-1} == 1 && -z ${__configs_greeted:-} && -t 1 ]]; then
    __configs_greeting
    __configs_greeted=1
fi

# Optional Fish-like editing. Load only in a real interactive terminal.
if [[ ${CONFIGS_BLESH:-1} == 1 && -z ${BLE_VERSION:-} && ${TERM:-dumb} != dumb && -t 0 && -t 1 ]]; then
    if [[ -r ${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh ]]; then
        source -- "${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh" --attach=none
        [[ ! ${BLE_VERSION:-} ]] || ble-attach
    fi
fi
