export ZSH="/home/anoma1y/.oh-my-zsh"

cfg="$HOME"'/.config'

source "$cfg"'/bash/aliases.sh'
source "$cfg"'/bash/exports.sh'

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

unset cfg
