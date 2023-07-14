emulate bash -c "source ~/.config/shell/aliases"
emulate bash -c "source ~/.config/shell/env"
emulate bash -c "source ~/.config/shell/functions"
emulate bash -c "source ~/.config/shell/tokens"

autoload -Uz compinit promptinit vcs_info bashcompinit

zle -N fzf-history-widget-accept

HISTFILE=$HOME/.zsh_history
SAVEHIST=2000000
HISTSIZE=2000000

set append_history
set inc_append_history
set share_history

setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

setopt KSH_ARRAYS

#PATHS
PATH=/usr/local/opt/libxml2/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/inetutils/libexec/gnubin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:$HOME/.ghcup/bin:$HOME/.ghcup/env:/usr/X11:/usr/X11/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/bin::/usr/local/opt/inetutils/libexec/gnubin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:$HOME/.ghcup/bin:$HOME/.ghcup/env:/usr/X11:/usr/X11/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$HOME/Library/Python/3.7/bin:/usr/local/opt/llvm/bin:$HOME/Library/Python/3.8/bin:$HOME/node_modules/.bin:/usr/bin:/bin:/usr/sbin:/sbin:$GOBIN:/home/busypanini/.cargo/bin

FPATH=$FPATH:$HOME/.config/zsh/completions

MANPATH=/usr/local/opt/coreutils/libexec/gnuman:/usr/local/share/man:$MANPATH

source ~/.config/shell/fzf/key-bindings.zsh

export VISUAL=nvim
export EDITOR=nvim

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Prompt and readline setup
precmd() { vcs_info }

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%F{blue]%}%b%f %F{red}%u%f %F{green}%c%f"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr ''
zstyle ':vcs_info:*' unstagedstr ''

promptinit
compinit
bashcompinit

_fix_cursor() {
   echo -ne '\e[5 q'
}

zstyle ':completion:*' menu select
setopt COMPLETE_ALIASES

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
autoload -U select-word-style
select-word-style bash

bindkey -v
bindkey '^[^?' backward-kill-word
bindkey "^?" backward-delete-char
bindkey "^R" history-incremental-search-backward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[f" forward-word
bindkey "^[b" backward-word
bindkey "^[." insert-last-word
bindkey '^[[Z' reverse-menu-complete #shift-tab

KEYTIMEOUT=1

precmd_functions+=(_fix_cursor)

function _pwd() {
	if [[ "$PWD" == "$HOME" ]]; then
		echo "~"

		return
	fi

	local dirs=($(echo "$PWD" | sed "s#$HOME#~#" | sed 's/\//\n/g'))

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

function zle-line-init zle-keymap-select {
    MODE="${${KEYMAP/vicmd/NML}/(main|viins)/INS}"

    local _lineup=$'\e[1A'
    local _linedown=$'\e[1B'

    if [[ $MODE == "NML" ]]; then
        MODE="%F{yellow}NML%f"
    else
        MODE="%F{green}INS%f"
    fi

    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
    fi

    HOSTNAME=$(cat /etc/hostname)

    dir=$(_pwd)

    PROMPT='┌[%B%F{cyan}'$HOSTNAME'%f%b]─[%(?.%B%F{green}%?%f%b.%B%F{red}%?%f%b)]─[%B%F{green}'${vcs_info_msg_0_}'%f%b]─[%B%F{yellow}'${dir}'%f%b]
└['$MODE']─> '

    zle reset-prompt
}

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
    if [[ $(uname) =~ "Darwin" ]]; then
        echo "$CUTBUFFER" | pbcopy
    else
        if [[ -v WAYLAND_SESSION ]]; then
            echo "$CUTBUFFER" | wl-copy
        else
            echo "$CUTBUFFER" | xsel -bi
        fi

    fi
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

zle -N zle-line-init
zle -N zle-keymap-select

if [[ $(uname) =~ "Linux" ]]; then
    #complete -C '/bin/aws_completer' aws
fi

if [[ $(uname) =~ "Linux" ]]; then
    if [[ $(tty) =~ "/dev/tty*" ]]; then
        if [[ $(tty) =~ "/dev/tty1" ]]; then
            trap exit SIGINT
            PS3="Choice > "

            select opt in Sway Plasma i3 Hyprland; do
                case $opt in
                    Plasma)
                        if ! startplasma-wayland; then
                            exit
                        fi
                        ;;
                    Sway)
                        export WLR_DRM_NO_MODIFIERS=1
                        if ! sway; then
                            exit
                        fi
                        ;;
                    i3)
                        if ! startx; then
                            exit
                        fi
                        ;;
                    Hyprland)
                        if ! Hyprland; then
                            exit
                        fi
                        ;;
                esac
            done

            exit
        fi

        sudo /usr/local/bin/tty-escape
    fi
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

