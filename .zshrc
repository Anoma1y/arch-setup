export ZSH="/home/anoma1y/.oh-my-zsh"

source "$HOME"'/.config/bash/aliases.sh'
source "$HOME"'/.config/bash/exports.sh'

ZSH_THEME="agnoster"

plugins=(
	command-not-found
	extract
	git
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
)

autoload -Uz compinit && compinit

source $ZSH/oh-my-zsh.sh

export SHELL="$(which zsh)"
