export ZSH="/home/anoma1y/.oh-my-zsh"

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

source "$HOME"'/.config/bash/aliases.sh'
source "$HOME"'/.config/bash/exports.sh'

export SHELL="$(which zsh)"
