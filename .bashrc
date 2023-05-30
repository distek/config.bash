#!/usr/bin/env bash

# Init {{{
# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

. ~/.config/shell/env
. ~/.config/shell/aliases
. ~/.config/shell/functions
. ~/.config/shell/tokens

. ~/.config/shell/fzf/key-bindings.bash

shopt -s direxpand
shopt -s histappend

bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'

export HISTFILESIZE=2000000
export HISTSIZE=2000000
export HISTTIMEFORMAT='%F_%T '
export HISTCONTROL=ignoreboth
# }}}

# Colors {{{
BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
NORMAL="\e[0m"

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
# }}}

# Vi-mode {{{
bind 'set editing-mode vi'
bind 'set show-mode-in-prompt on'
bind 'set vi-cmd-mode-string "└['${YELLOW}'NRM'${NORMAL}']─> \1\e[2 q\2"'}
bind 'set vi-ins-mode-string "└['${CYAN}'INS'${NORMAL}']─> \1\e[6 q\2"'
bind 'set keymap vi-insert'
bind '"\C-A": beginning-of-line'
bind '"\C-B": backward-char'
bind '"\C-D": delete-char'
bind '"\C-E": end-of-line'
bind '"\C-F": forward-char'
bind '"\C-K": kill-line'
bind '"\C-L": clear-screen'
bind '"\C-N": next-history'
bind '"\C-P": previous-history'
bind '"\C-O": operate-and-get-next'

bind '"\e.": yank-last-arg'
bind '"\e\177": backward-kill-word'
bind '"\e0": digit-argument'
bind '"\e1": digit-argument'
bind '"\e2": digit-argument'
bind '"\e3": digit-argument'
bind '"\e4": digit-argument'
bind '"\e5": digit-argument'
bind '"\e6": digit-argument'
bind '"\e7": digit-argument'
bind '"\e8": digit-argument'
bind '"\e9": digit-argument'
bind '"\eb": backward-word'

bind 'set keyseq-timeout 0'

set keyseq-timeout 0
# }}}

# Prompt {{{
_gitBranch() {
	local branch=$(git branch 2>/dev/null | grep "*" | sed 's/*\ //')
	if [ -z "$branch" ]; then
		echo -en "${BLACK}-${NORMAL}"
	else
		echo -en "${BLUE}${branch}${NORMAL}"
	fi

}

_errTest() {
	if (($1 != 0)); then
		echo -en ${RED}
	else
		echo -en ${GREEN}
	fi

	echo -e $1${NORMAL}
}

_pwd() {
	local dirs=($(echo "$PWD" | sed "s#$HOME#~#" | sed 's/\//\n/g'))

	if [[ "$PWD" == "$HOME" ]]; then
		echo "~"

		return
	fi

	local count=0
	for i in "${dirs[@]}"; do
		if [[ "$i" =~ "~" ]]; then
			echo -n "~"
			let count++
			continue
		fi

		if ((count == ${#dirs[@]} - 1)); then
			echo -n "/${i}"

			return
		else
			if ((${#i} > 3)); then
				echo -n "/${i:0:3}…"
			else
				echo -n "/${i}"
			fi

			let count++
		fi
	done
}

_prompt() {
	PS1="${NORMAL}┌[${GREEN}\h${NORMAL}]─[\$(_gitBranch)]─[\$(_errTest $?)]─[${YELLOW}\$(_pwd)${NORMAL}]\r\n${NORMAL}"
}

PROMPT_COMMAND=_prompt
# }}}

# Linux specific{{{
if [[ $(uname) =~ "Linux" ]]; then
	if [[ $(tty) =~ "/dev/tty1" ]]; then
		trap exit SIGINT
		PS3="Choice > "

		select opt in Sway Plasma i3; do
			case $opt in
			Plasma)
				if ! startplasma-wayland; then
					exit
				fi
				;;
			Sway)
				if ! sway; then
					exit
				fi
				;;
			i3)
				if ! startx; then
					exit
				fi
				;;
			esac
		done

		exit
	fi

	sudo /usr/local/bin/tty-escape
fi
# }}}
