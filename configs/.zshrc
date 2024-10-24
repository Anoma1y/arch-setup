export ZSH="$HOME/.oh-my-zsh"
export TERM=alacritty

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

plugins=(
	command-not-found
	extract
	colored-man-pages
	git
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
)

# initialize the completion system
autoload -Uz compinit && compinit

source "$ZSH/oh-my-zsh.sh"
source "$HOME/.config/bash/_init.sh"
