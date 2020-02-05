time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

source ~/dotfiles/zsh/zshrc.sh
