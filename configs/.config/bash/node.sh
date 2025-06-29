#!/bin/bash

# Add global npm modules binaries to PATH.
PATH="$HOME/.node_modules/bin:$PATH"

alias pn=pnpm

# Lazy load nvm to save shell startup time ~1-3 seconds
function lazynvm() {
    unset -f nvm node npm yarn

    # Check if NVM directory is set, if not, set it to the user's nvm directory.
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"

    # Unset the npm_config_prefix to avoid conflicts with npm behavior.
    unset npm_config_prefix

    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

nvm() {
  lazynvm
  nvm "$@"
}

node() {
  lazynvm
  node "$@"
}

npm() {
  lazynvm
  npm "$@"
}

yarn() {
  lazynvm
  yarn "$@"
}
