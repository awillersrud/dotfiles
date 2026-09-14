#! /bin/zsh -

# Vars
	HISTFILE=~/.zsh_history
	SAVEHIST=1000 
	setopt inc_append_history # To save every command before it is executed 
	setopt share_history # setopt inc_append_history

	#git config --global push.default current

# Aliases
	#alias v="vim -p"
	alias ll='ls -G -la'
	alias jsonf='python -m json.tool'
	alias epoch='date -r'
  	alias g='openGitRepo'
	alias kube-port-forward='read -r namespace pod junk <<<"$(kubectl get pods -A | fzf)" && kubectl port-forward -n "$namespace" "pod/$pod" 8087:8080'
	mkdir -p /tmp/log
	
# Settings
	export VISUAL=vim

source ~/dotfiles/zsh/plugins/fixls.zsh

#Functions
	# Unzip to tmp folder and cd to that folder, "zd -" to change directory back to previous folder
	# Inspired by total commander style handling of zip files
	function zd() {
		if [[ "$1" == "-" ]]; then
			PREVIOUS_DIRECTORY=`cat ~/.zd_history`
			if [ ! -z "$PREVIOUS_DIRECTORY" ]; then
				cd $PREVIOUS_DIRECTORY;
				echo "" > ~/.zd_history
			fi
		else
			SOURCE_DIRECTORY=`pwd`
			TARGET=/tmp/unzip-`openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'`;
			unzip $1 -d $TARGET;
			echo $SOURCE_DIRECTORY > ~/.zd_history
			cd $TARGET;
		fi
	}

  function openGitRepo() {
    TARGET=`find ~/src -maxdepth 4 -name .git -type d | sed 's#/.git##g' | fzf`
    cd $TARGET 
  }

	# Loop a command and show the output in vim
	loop() {
		echo ":cq to quit\n" > /tmp/log/output 
		fc -ln -1 > /tmp/log/program
		while true; do
			cat /tmp/log/program >> /tmp/log/output ;
			$(cat /tmp/log/program) |& tee -a /tmp/log/output ;
			echo '\n' >> /tmp/log/output
			vim + /tmp/log/output || break;
			rm -rf /tmp/log/output
		done;
	}

# Custom cd
chpwd() ls

# For vim mappings: 
	stty -ixon

# Completions
# These are all the plugin options available: https://github.com/robbyrussell/oh-my-zsh/tree/291e96dcd034750fbe7473482508c08833b168e3/plugins
#
# Edit the array below, or relocate it to ~/.zshrc before anything is sourced
# For help create an issue at github.com/parth/dotfiles

autoload -U compinit

plugins=(
	docker
)

for plugin ($plugins); do
    fpath=(~/dotfiles/zsh/plugins/oh-my-zsh/plugins/$plugin $fpath)
done

compinit

source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/history.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/key-bindings.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/completion.zsh
#source ~/dotfiles/zsh/plugins/vi-mode.plugin.zsh
source ~/dotfiles/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source ~/dotfiles/zsh/keybindings.sh

# Fix for arrow-key searching
# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${terminfo[kcuu1]}" != "" ]]; then
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

source ~/dotfiles/zsh/prompt.sh
export PATH=$PATH:$HOME/dotfiles/utils
