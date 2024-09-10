#!/bin/bash

# Set the GOPATH environment variable to point to the user's go directory.
export GOPATH=~/go

# Add custom directories to the PATH for prioritizing binaries.
PATH="$HOME/.node_modules/bin:$PATH"  # Add global npm modules binaries to PATH.
PATH="$HOME/bin:$PATH"                # Add user's custom binaries to PATH.
PATH="$HOME/go/bin:$PATH"             # Add Go binaries to PATH.

# Set locale variables to ensure proper encoding and language settings.
export LC_ALL=en_US.UTF-8             # Set the entire system's locale to UTF-8.
export LANG=en_US.UTF-8               # Set language preferences to US English in UTF-8 encoding.

# Set npm's global configuration directory to avoid using the system-wide directory.
export npm_config_prefix=~/.node_modules

# Check if NVM (Node Version Manager) directory is set, if not, set it to the user's nvm directory.
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
# Unset the npm_config_prefix to avoid conflicts with npm behavior.
unset npm_config_prefix
# Source the nvm script to load NVM into the current shell session.
source /usr/share/nvm/nvm.sh
