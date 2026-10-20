# Keep noninteractive Fish silent (scripts, editor integrations, SSH commands).
if command -q nvim
    set -gx EDITOR nvim
end
set -gx CARGO_INCREMENTAL 1
set -gx RUST_BACKTRACE 1
if not status is-interactive
    return
end

abbr -a c cargo
abbr -a e nvim
#abbr -a vim 'nvim'
abbr -a m make
abbr -a g git
abbr -a gc 'git checkout'
abbr -a vimdiff 'nvim -d'
abbr -a ct 'cargo t'
abbr -a p 'sudo apt'
abbr -a up 'sudo apt update && sudo apt upgrade'

if command -q eza
	abbr -a l 'eza'
	abbr -a ls 'eza'
	abbr -a ll 'eza -l'
	abbr -a lll 'eza -la'
else if command -q exa
	abbr -a l 'exa'
	abbr -a ls 'exa'
	abbr -a ll 'exa -l'
	abbr -a lll 'exa -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
set -gx LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
set -gx LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
set -gx LESS_TERMCAP_me \e'[0m'           # end mode
set -gx LESS_TERMCAP_se \e'[0m'           # end standout-mode
set -gx LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
set -gx LESS_TERMCAP_ue \e'[0m'           # end underline
set -gx LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

# Set envvars since we don't have .pam_environment
set -q BROWSER; or set -gx BROWSER xdg-open
set -gx NAME "Pedro Gomes"
set -gx EMAIL pehgomess@gmail.com
set -gx CARGO_INCREMENTAL 1
set -gx RUST_BACKTRACE 1
set -gx LESS "-F -X -R"

# Fish should not add things to clipboard when killing
# See https://github.com/fish-shell/fish-shell/issues/772
set FISH_CLIPBOARD_CMD "cat"

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color yellow
	echo -n (whoami)
	set_color normal
	echo -n "@"
	set_color blue
	echo -n (hostname)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

function fish_greeting
    set_color brblack
    printf '\nOS: %s\nUptime: %s\nHostname: %s\n' (uname -ro) (uptime -p) (hostname)
    set_color normal
    printf '\nDisk usage:\n'
    df -h -l -x tmpfs -x devtmpfs
    if command -q ip
        printf '\nNetwork:\n'
        ip -brief address show up
    end
    printf '\n'
    set -l fortune_cmd (command -s fortune)
    if test -z "$fortune_cmd"; and test -x /usr/games/fortune
        set fortune_cmd /usr/games/fortune
    end
    set -l fortune_dir "$HOME/.local/share/fortunes"
    if set -q XDG_DATA_HOME
        set fortune_dir "$XDG_DATA_HOME/fortunes"
    end
    if test -n "$fortune_cmd"; and test -f "$fortune_dir/frasesfortune.dat"
        $fortune_cmd "$fortune_dir/frasesfortune"
    end
end
