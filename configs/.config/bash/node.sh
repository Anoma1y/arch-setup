#!/bin/bash

# Add global npm modules binaries to PATH.
PATH="$HOME/.node_modules/bin:$PATH"

# Set npm's global configuration directory to avoid using the system-wide directory.
export npm_config_prefix=~/.node_modules

# Check if NVM (Node Version Manager) directory is set, if not, set it to the user's nvm directory.
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"

# Unset the npm_config_prefix to avoid conflicts with npm behavior.
unset npm_config_prefix

# Lazy load nvm to save shell startup time ~1-3 seconds
lazyload nvm "source ~/.nvm/nvm.sh"
