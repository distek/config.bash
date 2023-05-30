# .bashrc

TERM=xterm-256color


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export BASHCONF=$HOME/.config/bash

export PATH=$HOME/.local/bin:$PATH:$HOME/opt/REAPER/:$HOME/opt/firefox/:$HOME/.gem/ruby/2.6.0/bin:$HOME/.gem/ruby/2.7.0/bin:$HOME/Programming/golang/bin:$HOME/.cargo/bin
export VST_PATH=$VST_PATH:$HOME/wineVSTs/so/:/usr/lib/vst/:/usr/lib/vst3/:$HOME/wineVSTs/linvst-so:/usr/lib/vst/carla.vst:$HOME/.vst:$HOME/.vst3
export GOPATH=$HOME/Programming/golang
export GOSRC=$HOME/Programming/golang/src
export GOME=$HOME/Programming/golang/src/local/distek.local
export GOGITHUB=$HOME/Programming/golang/src/github.com/distek


bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'

shopt -s direxpand
shopt -s histappend

export HISTFILESIZE=2000000
export HISTSIZE=2000000
export HISTTIMEFORMAT='%F_%T '
export HISTCONTROL=ignoreboth

PROMPT_COMMAND='history -a'

if [ -f $HOME/.profile ]; then
    . $HOME/.profile
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

GPG_TTY=$(tty)
export GPG_TTY

# get current branch in git repo
parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]; then
		STAT=`parse_git_dirty`
		echo "${BRANCH}${STAT}"
	else
		echo "-"
	fi
}

# get current status of git repo
parse_git_dirty() {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

nonzero_return() {
    eval exitVal=$(echo $?)
    if [[ $exitVal > 0 ]]; then
        echo -e "\e[31m$exitVal\e[0m"
    else
        echo -e "\e[32m$exitVal\e[0m"
    fi
}

PROMPT_DIRTRIM=3
PS1="╭[\[\e[36m\]\h\[\e[m\]]─[\[\e[33m\]\w\[\e[m\]]─[\`nonzero_return\`]─[\[\e[36m\]\`parse_git_branch\`\[\e[m\]]\n"

# Bottom of prompt is in ~/.inputrc

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

if [ -f $BASHCONF/aliases ]; then
    . $BASHCONF/aliases
fi

if [ -f $BASHCONF/functions ]; then
    . $BASHCONF/functions
fi

bind -m emacs-standard '"\er": redraw-current-line'
bind -m emacs-standard -x '"\C-r": __fzf_history__'

bind -m vi-insert '"\er": redraw-current-line'
bind -m vi-insert -x '"\C-r": __fzf_history__'

bind -m vi-command '"\er": redraw-current-line'
bind -m vi-command -x '"\C-r": __fzf_history__'


# This is dumb
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin:$HOME/opt"

export NODE_PATH="/home/distek/node_modules"

# . $HOME/.cache/wal/colors-tty.sh

complete -C /home/distek/Programming/golang/bin/gocomplete go
