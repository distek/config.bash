#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------
__fzf_select__() {
	local cmd opts
	cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
	opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
	eval "$cmd" |
		FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@" |
		while read -r item; do
			printf '%q ' "$item" # escape special chars
		done
}

if [[ $- =~ i ]]; then

	__fzfcmd() {
		[[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
			echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
	}

	fzf-file-widget() {
		local selected="$(__fzf_select__ "$@")"
		READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + ${#selected}))
	}

	__fzf_cd__() {
		local cmd opts dir
		cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
		opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} +m"
		dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)) && printf 'builtin cd -- %q' "$dir"
	}

	__fzf_history__() {
		local output opts script
		opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
		script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
		output=$(
			builtin fc -lnr -2147483648 |
				last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$script" |
				FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
		) || return
		READLINE_LINE=${output#*$'\t'}
		if [[ -z "$READLINE_POINT" ]]; then
			echo "$READLINE_LINE"
		else
			READLINE_POINT=0x7fffffff
		fi
	}

	__fzf_project__() {
		local projectsDir=~/.local/share/nvim/sessions
		local projectFiles=($(ls -1t $projectsDir | sed "s#^#${projectsDir}/#"))

		local projectNames=($(for p in "${projectFiles[@]}"; do
			grep '" name:' "$p" | cut -d ':' -f2
		done))

		local projectDirs=($(for p in "${projectFiles[@]}"; do
			grep '" cwd:' "$p" | cut -d ':' -f2
		done))

		setopt localoptions pipefail no_aliases 2>/dev/null
		local projectName="$(for p in "${projectNames[@]}"; do echo "$p"; done | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
		if [[ -z "$projectName" ]]; then
			return
		fi

		local idx=9999
		for ((i = 0; i < "${#projectFiles[@]}"; i++)); do
			if grep '" name:'"${projectName}" ${projectFiles[$i]} &>/dev/null; then
				idx=$i
				break
			fi
		done

		if ((idx == 9999)); then
			return
		fi

		printf " builtin cd -- ${projectDirs[$idx]}; vim -c 'SessionLoad "${projectName}"'"
	}

	# Required to refresh the prompt after fzf
	bind -m emacs-standard '"\er": redraw-current-line'

	bind -m vi-command '"\C-z": emacs-editing-mode'
	bind -m vi-insert '"\C-z": emacs-editing-mode'
	bind -m emacs-standard '"\C-z": vi-editing-mode'

	if ((BASH_VERSINFO[0] < 4)); then
		# CTRL-T - Paste the selected file path into the command line
		bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
		bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
		bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'

		# CTRL-R - Paste the selected command from history into the command line
		bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u"$(__fzf_history__)"\e\C-e\er"'
		bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
		bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
	else
		# CTRL-T - Paste the selected file path into the command line
		bind -m emacs-standard -x '"\C-t": fzf-file-widget'
		bind -m vi-command -x '"\C-t": fzf-file-widget'
		bind -m vi-insert -x '"\C-t": fzf-file-widget'

		# CTRL-R - Paste the selected command from history into the command line
		bind -m emacs-standard -x '"\C-r": __fzf_history__'
		bind -m vi-command -x '"\C-r": __fzf_history__'
		bind -m vi-insert -x '"\C-r": __fzf_history__'
	fi

	# ALT-C - cd into the selected directory
	bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
	bind -m vi-command '"\ec": "\C-z\ec\C-z"'
	bind -m vi-insert '"\ec": "\C-z\ec\C-z"'

	# ALT-P - cd into project dir and start vim
	bind -m emacs-standard '"\ep": " \C-b\C-k \C-u`__fzf_project__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
	bind -m vi-command '"\ep": "\C-z\ep\C-z"'
	bind -m vi-insert '"\ep": "\C-z\ep\C-z"'
fi
