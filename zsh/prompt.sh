# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

# Supported colors: red, blue, green, cyan, yellow, magenta, black, & white
autoload -U colors && colors

# PS1 is rebuilt before every prompt, so PROMPT_SUBST is not needed. Leaving it off
# keeps branch and directory names from being executed as $(...) when the prompt is drawn.
unsetopt PROMPT_SUBST

set_prompt() {

	# [
	PS1="[ "

	# Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
	PS1+="%{$fg_bold[white]%}%~%{$reset_color%}"

	# Status Code
	#PS1+='%(?.., %{$fg[red]%}%?%{$reset_color%})'

	# Git: one status call gives branch, upstream, ahead/behind and changed files
	local GIT_STATUS line BRANCH UPSTREAM AHEAD_BEHIND AHEAD BEHIND
	local -i STATUS=0
	if GIT_STATUS=$(git status --porcelain=v2 --branch 2> /dev/null); then
		for line in ${(f)GIT_STATUS}; do
			case $line in
				'# branch.head '*) BRANCH=${line#\# branch.head } ;;
				'# branch.upstream '*) UPSTREAM=${line#\# branch.upstream } ;;
				'# branch.ab '*) AHEAD_BEHIND=${line#\# branch.ab } ;;
				'#'*) ;;
				*) STATUS+=1 ;;
			esac
		done
		[[ $BRANCH == '(detached)' ]] && BRANCH=HEAD

		PS1+=' | '
		PS1+="%{$fg[green]%}${BRANCH//\%/%%}%{$reset_color%}"
		# branch.ab is missing when there is no upstream or it no longer exists
		if [[ -n $AHEAD_BEHIND ]]; then
			if [[ "origin/$BRANCH" != $UPSTREAM ]]; then
				PS1+="%{$fg[yellow]%} -> ${UPSTREAM//\%/%%}%{$reset_color%}"
			fi

			AHEAD=${${AHEAD_BEHIND%% *}#+}
			BEHIND=${${AHEAD_BEHIND##* }#-}
			if (( BEHIND > 0 )); then
				PS1+="%{$fg[yellow]%} behind $BEHIND%{$reset_color%}"
			fi
			if (( AHEAD > 0 )); then
				PS1+="%{$fg[yellow]%} ahead $AHEAD%{$reset_color%}"
			fi
		else
			PS1+="%{$fg[yellow]%} no-upstream%{$reset_color%}"
		fi
		if (( STATUS > 0 )); then
			PS1+="%{$fg[yellow]%} +$STATUS%{$reset_color%}"
		fi
	fi

	# Display non-default JDK
	JDK=${JAVA_HOME:+`readlink -f $JAVA_HOME | rev | cut -d'/' -f 1 | rev`}
	if [[ -n $JDK && $JDK != *"21.0.1-tem"* ]]; then
		PS1+=' | '
		PS1+="%{$fg[cyan]%}$JDK%{$reset_color%}"
	fi


	# Timer: http://stackoverflow.com/questions/2704635/is-there-a-way-to-find-the-running-time-of-the-last-executed-command-in-the-shel
	#if [[ $_elapsed[-1] -ne 0 ]]; then
	#	PS1+=', '
	#	PS1+="%{$fg[magenta]%}$_elapsed[-1]s%{$reset_color%}"
	#fi

	# PID
	if [[ $! -ne 0 ]]; then
		PS1+=' | '
		PS1+="%{$fg[yellow]%}PID:$!%{$reset_color%}"
	fi

	# Sudo: only ask sudo whether credentials are cached shortly after a command used it
	if (( EPOCHSECONDS - SUDO_LAST_USED < SUDO_CACHE_SECONDS )) && sudo -n true 2> /dev/null; then
		PS1+=' | '
		PS1+="%{$fg_bold[red]%}SUDO%{$reset_color%}"
	fi

	# ]
	PS1+=" ]≫ "
}

precmd_functions+=set_prompt

# Sudo caches credentials per terminal for 5 minutes by default, and only root can read
# that cache. Remember when this shell last ran sudo so the prompt can skip the check otherwise.
zmodload zsh/datetime
SUDO_CACHE_SECONDS=300
SUDO_LAST_USED=0

record_sudo_use() {
	# $3 is the command line with aliases expanded
	if [[ $3 =~ '(^|[^[:alnum:]_-])sudo($|[^[:alnum:]_-])' ]]; then
		SUDO_LAST_USED=$EPOCHSECONDS
	fi
}
preexec_functions+=record_sudo_use

preexec () {
   (( ${#_elapsed[@]} > 1000 )) && _elapsed=(${_elapsed[@]: -1000})
   _start=$SECONDS
}

precmd () {
   (( _start >= 0 )) && _elapsed+=($(( SECONDS-_start )))
   _start=-1 
}
