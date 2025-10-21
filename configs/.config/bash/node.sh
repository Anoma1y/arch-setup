#!/bin/bash

# Add global npm modules binaries to PATH.
PATH="$HOME/.node_modules/bin:$PATH"

alias pn=pnpm

lazy_load_nvm() {
  unset -f npm node nvm pnpm yarn
  export NVM_DIR=~/.nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

nvm() {
  lazy_load_nvm
  nvm "$@"
}

node() {
  lazy_load_nvm
  node "$@"
}

npm() {
  lazy_load_nvm
  npm "$@"
}

yarn() {
  lazy_load_nvm
  yarn "$@"
}

pnpm() {
  lazy_load_nvm
  pnpm "$@"
}
