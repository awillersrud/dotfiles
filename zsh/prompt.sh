# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

# Supported colors: red, blue, green, cyan, yellow, magenta, black, & white
autoload -U colors && colors

setopt PROMPT_SUBST

set_prompt() {

	# [
	PS1="[ "

	# Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
	PS1+="%{$fg_bold[white]%}${PWD/#$HOME/~}%{$reset_color%}"

	# Status Code
	#PS1+='%(?.., %{$fg[red]%}%?%{$reset_color%})'

 	# Git
 	if git rev-parse --is-inside-work-tree 2> /dev/null | grep -q 'true' ; then
 		PS1+=' | '
 		PS1+="%{$fg[green]%}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
		BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
		UPSTREAM=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
		if [[ $? == 0 ]]; then
			if [[ "origin/$BRANCH" != $UPSTREAM ]]; then
				PS1+="%{$fg[yellow]%} -> $UPSTREAM%{$reset_color%}"
			fi

			BEHIND=$(git log ..@{upstream} --oneline 2> /dev/null | wc -l)
			if [ $BEHIND -gt 0 ]; then
				PS1+="%{$fg[yellow]%} behind $(echo $BEHIND | awk '{$1=$1};1')%{$reset_color%}"
			fi
			AHEAD=$(git log @{upstream}.. --oneline 2> /dev/null | wc -l)
			if [ $AHEAD -gt 0 ]; then
				PS1+="%{$fg[yellow]%} ahead $(echo $AHEAD | awk '{$1=$1};1')%{$reset_color%}"
			fi
		else
			PS1+="%{$fg[yellow]%} no-upstream%{$reset_color%}"
		fi
		STATUS=$(git status --short | wc -l)
		if [ $STATUS -gt 0 ]; then
			PS1+="%{$fg[yellow]%} +$(echo $STATUS | awk '{$1=$1};1')%{$reset_color%}"
		fi

		if [[ $JAVA_HOME != *"jdk1.8.0"* ]]; then
			PS1+=' | '
			PS1+="%{$fg[cyan]%}$(echo $JAVA_HOME | cut -d'/' -f 5)%{$reset_color%}"
		fi
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

	# Sudo: https://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
	CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
	if [ ${CAN_I_RUN_SUDO} -gt 0 ]
	then
		PS1+=' | '
		PS1+="%{$fg_bold[red]%}SUDO%{$reset_color%}"
	fi

	# ]
	PS1+=" ]≫ "
}

precmd_functions+=set_prompt

preexec () {
   (( ${#_elapsed[@]} > 1000 )) && _elapsed=(${_elapsed[@]: -1000})
   _start=$SECONDS
}

precmd () {
   (( _start >= 0 )) && _elapsed+=($(( SECONDS-_start )))
   _start=-1 
}
