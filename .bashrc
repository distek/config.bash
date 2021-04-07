# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

export BASHCONF=$HOME/.config/bash

export PATH=$HOME/.local/bin:$PATH:$HOME/opt/REAPER/:$HOME/opt/firefox/:$HOME/.gem/ruby/2.6.0/bin:$HOME/.gem/ruby/2.7.0/bin:$HOME/Programming/golang/bin:$HOME/.cargo/bin
export VST_PATH=$VST_PATH:$HOME/wineVSTs/so/:/usr/lib/vst/:/usr/lib/vst3/:$HOME/wineVSTs/linvst-so:/usr/lib/vst/carla.vst:$HOME/.vst:$HOME/.vst3
export GOPATH=$HOME/Programming/golang
export GOSRC=$HOME/Programming/golang/src

if [[ "$(uname)" == "Linux" ]]; then
    systemctl --user import-environment PATH
fi

# If wanted, this starts a tmux session if none exists, or creates a
# new session if tmux is already running (if not in a linux term)
#[[ -z "$TMUX" && $(tty) != /dev/tty[0-9] ]] && { tmux || exec tmux new-session && exit;}
shopt -s direxpand

shopt -s histappend
export HISTFILESIZE=2000000
export HISTSIZE=2000000
export HISTTIMEFORMAT='%F_%T '
export HISTCONTROL=ignoreboth

PROMPT_COMMAND='history -a'

. ~/.profile

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

PS1="[\[\e[33;1m\]\w\[\e[0m\]] [\[\e[36;1m\]\H\[\e[0m\]] [\[\e[33;1m\]\$?\[\e[0m\]] \n[\[\e[34;1m\]\u\[\e[0m\]] > "

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

if [ -f $BASHCONF/aliases ]; then
    . $BASHCONF/aliases
fi

if [ -f $BASHCONF/functions ]; then
    . $BASHCONF/functions
fi

# This is dumb
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin:$HOME/opt"
