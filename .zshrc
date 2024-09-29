export ZSH="/home/anoma1y/.oh-my-zsh"

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

plugins=(
	command-not-found
	extract
	git
	colored-man-pages
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
)

# initialize the completion system
autoload -Uz compinit && compinit

source $ZSH/oh-my-zsh.sh

source "$HOME/.config/bash/functions.sh"
source "$HOME/.config/bash/aliases.sh"
source "$HOME/.config/bash/exports.sh"
source "$HOME/.config/bash/nvm.sh"

export SHELL="$(which zsh)"
